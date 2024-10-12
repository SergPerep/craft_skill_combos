
  def get_refined_data() do
    input =
      File.read!("raw_input.csv")
      |> String.split("\n")
      |> Enum.map(fn line ->
        line = String.replace(line, " , ", "|") |> String.replace("\"", "") |> String.split(",")
        [Enum.at(line, 2), Enum.at(line, 3) |> String.trim() |> String.split("|", trim: true)]
      end)

    input = List.delete_at(input, 0)
    input = Enum.map(0..(length(input) - 1), fn index -> [index] ++ Enum.at(input, index) end)

    skills =
      Enum.reduce(input, [], fn item, acc -> acc ++ Enum.at(item, 2) end)
      |> Enum.uniq()
      |> Enum.with_index(fn skill_name, index -> [index, skill_name] end)

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

    [skills, crafts]
  end
