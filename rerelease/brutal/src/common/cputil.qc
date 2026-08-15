// Shared Combat Plus helpers compiled before items/weapons

float(float have, float add, float cap) CP_AmmoRoom =
{
	local float room;

	room = cap - have;
	if (room <= 0)
		return 0;
	if (add < room)
		return add;
	return room;
};
