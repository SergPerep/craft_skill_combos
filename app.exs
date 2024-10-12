Code.require_file("modules.exs")

{all_skills, all_crafts} = Hours.read_dicts()
# [all_skills, all_crafts] = Hours.exclude_skills_and_crafts([], all_skills, [0], all_crafts)
# all_crafts = Hours.sort_crafts_by_number_of_skills(all_crafts)
# all_skills = Hours.sort_skills_by_number_of_crafts(all_skills)
start_time = DateTime.utc_now()

IO.inspect([all_skills, all_crafts], charlists: :as_lists)

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
