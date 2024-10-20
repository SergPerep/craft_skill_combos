Code.require_file("modules.exs")

{skill_dict, craft_dict} = Hours.read_dicts()
# mandatory_skill_ids = []
# ignore_skill_ids = []
# ignore_craft_ids = []
mandatory_skill_ids = [59,58, 6, 57, 0, 3, 19, 40, 18, 21, 49, 50, 16, 42]
ignore_skill_ids = [46, 30, 45, 76, 39, 15]
ignore_craft_ids = [44, 39]
[all_skills, all_crafts] =
  Enum.map([skill_dict, craft_dict], fn dict ->
    Enum.map(dict, fn line ->
      List.delete_at(line, 1)
    end)
  end)

[all_skills, all_crafts] =
  Hours.exclude_skills_and_crafts(ignore_craft_ids, all_skills, ignore_skill_ids, all_crafts)

{all_skills, all_crafts} =
  Hours.filter_out_mandatory_skills(mandatory_skill_ids, all_skills, all_crafts)

[crucial_skill_ids, _necessary_skill_ids, _journey] =
  Hours.get_necessary_skill_ids(all_skills, all_crafts)

all_crafts = Hours.sort_crafts_by_number_of_skills(all_crafts)
all_skills = Hours.sort_skills_by_number_of_crafts(all_skills)
start_time = DateTime.utc_now()

# IO.inspect(crucial_skill_ids, charlists: :as_lists)

# Enum.each(all_skills, fn sk -> List.first(sk) |> Hours.get_name_by_id(skill_dict) |> IO.inspect() end)

# IO.inspect([all_skills, all_crafts], charlists: :as_lists)

skill_ids =
Hours.make_journey(all_skills, all_crafts)
|> Enum.map(fn j ->
  Enum.map(j, fn step ->
    [target_craft_id, sk_pos, _max] = step

    Enum.find(all_crafts, fn craft -> List.first(craft) === target_craft_id end)
    |> List.last()
    |> Enum.at(sk_pos)
  end)
  |> Enum.sort(:desc)
end)
|> Enum.uniq()
|> Enum.random()

Enum.each(mandatory_skill_ids, fn id -> IO.puts(Hours.get_name_by_id(id, skill_dict)) end)
IO.puts("---")
Enum.each(crucial_skill_ids, fn id -> IO.puts(Hours.get_name_by_id(id, skill_dict)) end)
IO.puts("---")
Enum.each(skill_ids, fn id -> IO.puts(Hours.get_name_by_id(id, skill_dict)) end)

# |> length()
# IO.inspect(skill_ids, charlists: :as_lists)

IO.puts(Integer.to_string(DateTime.diff(DateTime.utc_now(), start_time, :second)) <> " s")
