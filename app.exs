Code.require_file("modules.exs")

{skill_dict, craft_dict} = Hours.read_dicts()
mandatory_skill_ids = [0]

[all_skills, all_crafts] =
  Enum.map([skill_dict, craft_dict], fn dict ->
    Enum.map(dict, fn line ->
      List.delete_at(line, 1)
    end)
  end)

[all_skills, all_crafts] =
  Hours.exclude_skills_and_crafts([44, 39, 16], all_skills, [46, 30, 45, 76, 39, 15], all_crafts)

{all_skills, all_crafts} = Hours.filter_out_mandatory_skills(mandatory_skill_ids, all_skills, all_crafts)
[crucial_skill_ids, _necessary_skill_ids, _journey] =
    Hours.get_necessary_skill_ids(all_skills, all_crafts)
all_crafts = Hours.sort_crafts_by_number_of_skills(all_crafts)
all_skills = Hours.sort_skills_by_number_of_crafts(all_skills)
start_time = DateTime.utc_now()



IO.inspect(crucial_skill_ids, charlists: :as_lists)

# Enum.each(all_skills, fn sk -> List.first(sk) |> Hours.get_name_by_id(skill_dict) |> IO.inspect() end)

# IO.inspect([all_skills, all_crafts], charlists: :as_lists)

# Hours.make_journey(all_skills, all_crafts)
# |> Enum.map(fn j ->
#   Enum.map(j, fn step ->
#     [target_craft_id, sk_pos, _max] = step

#     Enum.find(all_crafts, fn craft -> List.first(craft) === target_craft_id end)
#     |> List.last()
#     |> Enum.at(sk_pos)
#   end)
#   |> Enum.sort(:desc)
# end)
# |> Enum.uniq()
# |> length()
# |> IO.inspect(charlists: :as_lists)

IO.puts(Integer.to_string(DateTime.diff(DateTime.utc_now(), start_time, :second)) <> " s")
