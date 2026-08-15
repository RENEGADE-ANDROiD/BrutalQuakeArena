import json
import os
import shutil
import struct
import subprocess

ROOT = r"E:\SteamLibrary\steamapps\common\Quake\rerelease"
SRC = os.path.join(ROOT, "brutal", "src")
VENDOR = os.path.join(ROOT, "brutal", "vendor", "quake_authmdl")
FARENA = os.path.join(ROOT, "brutal", "vendor", "farena")
BRUTAL = os.path.join(ROOT, "brutal")
AUTHMDL_URL = "https://github.com/NightFright2k19/quake_authmdl.git"
ROGUE_PAK0 = os.path.join(ROOT, "rogue", "pak0.pak")
HIP_PAK0 = os.path.join(ROOT, "hipnotic", "pak0.pak")
ID1_PAK0 = os.path.join(ROOT, "id1", "pak0.pak")


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


def load_json_bytes(raw):
    if raw.startswith(b"\xef\xbb\xbf"):
        raw = raw[3:]
    return json.loads(raw.decode("utf-8"))


def merge_id1_mapdb():
    """Official id1 mapdb plus Rocket Arena. Do not edit vanilla pak0.pak."""
    official = load_json_bytes(read_pak(ID1_PAK0)["mapdb.json"])
    brutal_path = os.path.join(BRUTAL, "mapdb.json")
    with open(brutal_path, "rb") as f:
        arena = load_json_bytes(f.read())
    episodes = list(official.get("episodes", []))
    maps = list(official.get("maps", []))
    have_ep = {ep.get("dir") for ep in episodes}
    for ep in arena.get("episodes", []):
        if ep.get("dir") not in have_ep:
            episodes.append(ep)
            have_ep.add(ep.get("dir"))
    have_bsp = {m.get("bsp") for m in maps}
    added = 0
    for m in arena.get("maps", []):
        if m.get("bsp") in have_bsp:
            continue
        maps.append(m)
        have_bsp.add(m.get("bsp"))
        added += 1
    merged = {"episodes": episodes, "maps": maps}
    blob = (json.dumps(merged, indent=2, ensure_ascii=True) + "\n").encode("utf-8")
    print(
        "merged mapdb episodes=%d maps=%d (+%d arena)"
        % (len(episodes), len(maps), added)
    )
    return blob


def ensure_farena_loose():
    """One copy of Final Arena maps/sounds under game brutal. Do not pack into every campaign."""
    if not os.path.isdir(FARENA):
        print("no vendor/farena (extract farena12 pak0.pak there)")
        return
    copied = 0
    for dirpath, _dirs, names in os.walk(FARENA):
        rel = os.path.relpath(dirpath, FARENA)
        for name in names:
            if name.lower() == "readme.txt":
                continue
            src = os.path.join(dirpath, name)
            if rel == ".":
                dest = os.path.join(BRUTAL, name)
            else:
                dest = os.path.join(BRUTAL, rel, name)
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            if (not os.path.isfile(dest)) or os.path.getmtime(src) > os.path.getmtime(dest):
                shutil.copy2(src, dest)
                copied += 1
    print("farena loose files copied", copied)


ensure_authmdl()
ensure_farena_loose()

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

merged_mapdb = merge_id1_mapdb()
loose_id1_mapdb = os.path.join(ROOT, "id1", "mapdb.json")
with open(loose_id1_mapdb, "wb") as f:
    f.write(merged_mapdb)
print("wrote", loose_id1_mapdb)

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
    if dest == "id1":
        files["mapdb.json"] = merged_mapdb
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
