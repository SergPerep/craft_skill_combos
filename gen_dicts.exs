input =
  File.read!("raw_input_test.csv")
  |> String.split("\n")
  |> Enum.map(fn line ->
    line = String.replace(line, " , ", "|") |> String.replace("\"", "") |> String.split(",")
    [Enum.at(line, 2), Enum.at(line, 3) |> String.trim() |> String.split("|", trim: true)]
  end)

input = List.delete_at(input, 0)
input = Enum.map(0..(length(input) - 1), fn index -> [index] ++ Enum.at(input, index) end)

skill_names =
  Enum.reduce(input, [], fn item, acc -> acc ++ Enum.at(item, 2) end)

skills =
  Enum.uniq(skill_names)
  |> Enum.map(fn unique_name ->
    {unique_name, Enum.count(skill_names, fn sk_name -> sk_name === unique_name end)}
  end)
  |> Enum.sort(fn {_, num1}, {_, num2} -> num1 >= num2 end)
  |> Enum.with_index(fn {skill_name, _}, index -> [index, skill_name] end)

crafts =
  Enum.map(input, fn item ->
    [id, craft_name, skill_names] = item

    skill_ids =
      Enum.map(skill_names, fn skill_name ->
        [skill_id | _tail] =
          Enum.find(skills, fn skill -> Enum.at(skill, 1) === skill_name end)

        skill_id
      end)

    [id, craft_name, skill_ids]
  end)

skills =
  Enum.map(skills, fn sk ->
    [sk_id, sk_name] = sk

    sk_cr_ids =
      Enum.filter(crafts, fn craft ->
        [_cr_id, _cr_name, cr_sk_ids] = craft
        Enum.member?(cr_sk_ids, sk_id)
      end)
      |> Enum.map(fn cr -> List.first(cr) end)

    sk_cr_ids =
      Enum.map(sk_cr_ids, fn id ->
        Integer.to_string(id)
      end)
      |> Enum.join(", ")

    "#{Integer.to_string(sk_id)} | #{sk_name} | #{sk_cr_ids}"
  end)
  |> Enum.join("\n")

crafts =
  Enum.map(crafts, fn [id, craft_name, skill_ids] ->
    skill_ids =
      Enum.map(skill_ids, fn skill_id ->
        Integer.to_string(skill_id)
      end)
      |> Enum.join(", ")

    "#{Integer.to_string(id)} | #{craft_name} | #{skill_ids}"
  end)
  |> Enum.join("\n")

# IO.inspect(skills, charlists: :as_lists)
# IO.inspect(crafts, charlists: :as_lists)

File.write!("data/skill_dict.txt", skills)
File.write!("data/craft_dict.txt", crafts)
