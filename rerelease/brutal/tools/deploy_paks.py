import os
import shutil
import struct
import subprocess

ROOT = r"E:\SteamLibrary\steamapps\common\Quake\rerelease"
SRC = os.path.join(ROOT, "brutal", "src")
VENDOR = os.path.join(ROOT, "brutal", "vendor", "quake_authmdl")
AUTHMDL_URL = "https://github.com/NightFright2k19/quake_authmdl.git"
ROGUE_PAK0 = os.path.join(ROOT, "rogue", "pak0.pak")
HIP_PAK0 = os.path.join(ROOT, "hipnotic", "pak0.pak")


def read_pak(path):
    with open(path, "rb") as f:
        data = f.read()
    if data[:4] != b"PACK":
        raise SystemExit("not a pak: " + path)
    off, length = struct.unpack_from("<II", data, 4)
    n = length // 64
    files = {}
    for i in range(n):
        e = data[off + i * 64 : off + (i + 1) * 64]
        name = e[:56].split(b"\x00", 1)[0].decode("latin1")
        pos, size = struct.unpack_from("<II", e, 56)
        files[name] = data[pos : pos + size]
    return files


def write_pak(path, files):
    names = list(files.keys())
    payload = b""
    dirents = b""
    cursor = 12
    for name in names:
        blob = files[name]
        raw = name.encode("latin1")
        if len(raw) > 55:
            raise SystemExit("name too long: " + name)
        ent = raw + b"\x00" * (56 - len(raw))
        ent += struct.pack("<II", cursor, len(blob))
        dirents += ent
        payload += blob
        cursor += len(blob)
    header = b"PACK" + struct.pack("<II", cursor, len(dirents))
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "wb") as f:
        f.write(header + payload + dirents)
    return os.path.getsize(path)


def ensure_authmdl():
    if os.path.isdir(os.path.join(VENDOR, ".git")):
        return
    os.makedirs(os.path.dirname(VENDOR), exist_ok=True)
    print("cloning", AUTHMDL_URL)
    subprocess.check_call(["git", "clone", "--depth", "1", AUTHMDL_URL, VENDOR])


def add_dir(files, folder, pak_dir):
    """Add every file in folder. foo_alt.ext is packed as pak_dir/foo.ext so alts are live."""
    if not os.path.isdir(folder):
        print("missing folder", folder)
        return 0
    names = [n for n in os.listdir(folder) if os.path.isfile(os.path.join(folder, n))]
    ordered = [n for n in names if "_alt." not in n] + [n for n in names if "_alt." in n]
    added = 0
    for name in ordered:
        live = name.replace("_alt.", ".")
        pak_name = pak_dir + "/" + live
        with open(os.path.join(folder, name), "rb") as f:
            files[pak_name] = f.read()
        added += 1
        if "_alt." in name:
            print("alt as live", pak_name)
    return added


ensure_authmdl()

rogue_files = read_pak(ROGUE_PAK0)
hook = rogue_files.get("progs/hook.mdl")
if not hook:
    keys = [k for k in rogue_files if "hook" in k.lower()]
    raise SystemExit("progs/hook.mdl not in rogue pak0; keys: " + ", ".join(keys))
print("hook.mdl", len(hook), "bytes")

hip_files = read_pak(HIP_PAK0)
hammer_extra = {}
for name in (
    "progs/g_hammer.mdl",
    "progs/v_hammer.mdl",
    "sound/hipweap/mjolhit.wav",
    "sound/hipweap/mjolslap.wav",
    "sound/hipweap/mjoltink.wav",
):
    blob = hip_files.get(name)
    if not blob:
        print("missing hipnotic asset", name)
        continue
    hammer_extra[name] = blob
    print(name, len(blob), "bytes")

shared = {}
n_maps = add_dir(shared, os.path.join(VENDOR, "id1", "maps"), "maps")
n_progs = add_dir(shared, os.path.join(VENDOR, "id1", "progs"), "progs")
print("authmdl shared maps=%d progs=%d" % (n_maps, n_progs))

campaigns = {
    "id1": "id1",
    "hipnotic": "hipnotic",
    "rogue": "rogue",
    "mg1": "mg1",
    "ctf": "ctf",
    "dopa": "mg1",
}

for dest, src_name in campaigns.items():
    progs_path = os.path.join(SRC, src_name, "progs.dat")
    with open(progs_path, "rb") as f:
        progs = f.read()
    files = {
        "progs.dat": progs,
        "progs/hook.mdl": hook,
    }
    files.update(hammer_extra)
    files.update(shared)
    extra = 0
    if dest == "hipnotic":
        extra = add_dir(files, os.path.join(VENDOR, "hipnotic", "progs"), "progs")
    elif dest == "rogue":
        extra += add_dir(files, os.path.join(VENDOR, "rogue", "maps"), "maps")
        extra += add_dir(files, os.path.join(VENDOR, "rogue", "progs"), "progs")
    files["progs/hook.mdl"] = hook
    if "progs/g_hammer.mdl" in hammer_extra:
        files["progs/g_hammer.mdl"] = hammer_extra["progs/g_hammer.mdl"]
    dest_dir = os.path.join(ROOT, dest)
    pak1 = os.path.join(dest_dir, "pak1.pak")
    pak9 = os.path.join(dest_dir, "pak9.pak")
    size = write_pak(pak1, files)
    shutil.copyfile(pak1, pak9)
    loose_progs = os.path.join(dest_dir, "progs.dat")
    loose_hook_dir = os.path.join(dest_dir, "progs")
    os.makedirs(loose_hook_dir, exist_ok=True)
    with open(loose_progs, "wb") as f:
        f.write(progs)
    with open(os.path.join(loose_hook_dir, "hook.mdl"), "wb") as f:
        f.write(hook)
    if "progs/g_hammer.mdl" in files:
        with open(os.path.join(loose_hook_dir, "g_hammer.mdl"), "wb") as f:
            f.write(files["progs/g_hammer.mdl"])
        with open(os.path.join(loose_hook_dir, "v_hammer.mdl"), "wb") as f:
            f.write(files["progs/v_hammer.mdl"])
    print(
        "%s: pak1/pak9=%d  files=%d  extra=%d  progs.dat=%d"
        % (dest, size, len(files), extra, len(progs))
    )
