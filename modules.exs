defmodule Hours do
  def read_dicts() do
    [skill_dicts, craft_dicts] =
      Enum.map(["data/skill_dict.txt", "data/craft_dict.txt"], fn file_path ->
        File.read!(file_path)
        |> String.split("\n")
        |> Enum.map(fn line ->
          [id, name, ref_ids] = String.split(line, " | ", trim: true)
          {id, _} = Integer.parse(id)

          ref_ids =
            String.split(ref_ids, ", ")
            |> Enum.map(fn id ->
              {id, _} = Integer.parse(id)
              id
            end)

          [id, name, ref_ids]
        end)
      end)

    {skill_dicts, craft_dicts}
  end

  def get_name_by_id(id, skill_dict) do
    Enum.find(skill_dict, fn skill -> List.first(skill) === id end) |> Enum.at(1)
  end

  def get_refined_data(is_having_names \\ true) do
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

        [sk_id, sk_name, sk_cr_ids]
      end)

    {skills, crafts} =
      if is_having_names do
        {skills, crafts}
      else
        {
          Enum.map(skills, fn [id, _name, links] -> [id, links] end),
          Enum.map(crafts, fn [id, _name, links] -> [id, links] end)
        }
      end

    [skills, crafts]
  end

  def sort_crafts_by_number_of_skills(crafts),
    do: Enum.sort_by(crafts, fn craft -> List.last(craft) |> length() end)

  def sort_skills_by_number_of_crafts(skills),
    do: Enum.sort_by(skills, fn sk -> List.last(sk) |> length() end, :desc)

  def read_journey(journey, crucial_skills_ids, all_skills, all_crafts) do
    selected_skill_ids =
      crucial_skills_ids ++
        Enum.map(journey, fn j ->
          [craft_id, num, _max] = j

          get_skill_ids_by_craft_id(craft_id, all_crafts)
          |> Enum.at(num)
        end)

    selected_craft_ids =
      Enum.map(selected_skill_ids, fn sk_id ->
        get_crafts_ids_by_skill_id(sk_id, all_skills)
      end)
      |> List.flatten()
      |> Enum.uniq()

    rest_crafts =
      Enum.filter(all_crafts, fn cr ->
        !Enum.member?(selected_craft_ids, List.first(cr))
      end)

    [rest_crafts, selected_skill_ids]
  end

  def cut_journey([]), do: []

  def cut_journey(journey) do
    last_step = List.last(journey)
    [_, selected, max] = last_step

    if selected >= max do
      journey = List.delete(journey, last_step)
      cut_journey(journey)
    else
      journey
    end
  end

  def make_journey(all_skills, all_crafts) do
    [crucial_skill_ids, _sk_ids, first_journey] =
      get_necessary_skill_ids(all_skills, all_crafts)

    make_journey(
      first_journey,
      [first_journey],
      crucial_skill_ids,
      all_skills,
      all_crafts,
      length(first_journey)
    )
  end

  def make_journey(last_journey, journeys, crucial_skill_ids, all_skills, all_crafts, j_l_limit) do
    # IO.inspect(last_journey, charlists: :as_lists)

    {j_l_limit, journeys} =
      if j_l_limit === nil do
        {length(all_crafts), journeys}
      else
        if length(last_journey) < j_l_limit do
          j_l_limit = length(last_journey)
          IO.puts("New limit: " <> Integer.to_string(j_l_limit))
          journeys = Enum.filter(journeys, fn j -> length(j) <= j_l_limit end)
          {j_l_limit, journeys}
        else
          {j_l_limit, journeys}
        end
      end

    curr_journey = cut_journey(last_journey)

    if length(curr_journey) === 0 do
      journeys
    else
      curr_journey =
        List.update_at(curr_journey, length(curr_journey) - 1, fn step ->
          List.update_at(step, 1, &(&1 + 1))
        end)

      [rest_crafts, selected_skill_ids] =
        read_journey(curr_journey, crucial_skill_ids, all_skills, all_crafts)

      ## Continue journey

      {status, _selected_skill_ids, curr_journey} =
        next_craft(rest_crafts, selected_skill_ids, all_skills, curr_journey, j_l_limit)

      journeys =
        if(status === :ok) do
          # IO.inspect(curr_journey)
          [curr_journey | journeys]
        else
          journeys
        end

      ## Make another journey
      make_journey(curr_journey, journeys, crucial_skill_ids, all_skills, all_crafts, j_l_limit)
    end
  end

  def get_crafts_ids_by_skill_id(skill_id, skills) do
    Enum.find(skills, &(List.first(&1) === skill_id))
    |> List.last()
  end

  def next_craft([], selected_skill_ids, _all_skills, journey, _j_l_limit) do
    {:ok, selected_skill_ids, journey}
  end

  def next_craft(rest_crafts, selected_skill_ids, all_skills, journey, j_l_limit) do
    if length(journey) >= j_l_limit do
      {:bad, selected_skill_ids, journey}
    else
      {craft, rest_crafts} = List.pop_at(rest_crafts, 0)

      can_already_craft =
        List.last(craft)
        |> Enum.reduce_while(false, fn skill_id, _acc ->
          if Enum.member?(selected_skill_ids, skill_id) do
            {:halt, true}
          else
            {:cont, false}
          end
        end)

      if can_already_craft do
        next_craft(rest_crafts, selected_skill_ids, all_skills, journey, j_l_limit)
      else
        skill_id = List.last(craft) |> List.first()
        cr_ids = get_crafts_ids_by_skill_id(skill_id, all_skills)

        rest_crafts =
          Enum.filter(rest_crafts, fn craft -> !Enum.member?(cr_ids, List.first(craft)) end)

        selected_skill_ids = [skill_id | selected_skill_ids]
        journey = journey ++ [[List.first(craft), 0, length(List.last(craft)) - 1]]
        next_craft(rest_crafts, selected_skill_ids, all_skills, journey, j_l_limit)
      end
    end
  end

  def exclude_skills_and_crafts(skills_ids_to_exclude, skills, crafts_ids_to_exclude, crafts) do
    skills =
      Enum.filter(skills, fn sk ->
        !Enum.member?(skills_ids_to_exclude, List.first(sk))
      end)

    crafts =
      Enum.filter(crafts, fn craft ->
        !Enum.member?(crafts_ids_to_exclude, List.first(craft))
      end)

    crafts =
      Enum.map(crafts, fn [cr_id, sk_ids] ->
        sk_ids =
          Enum.filter(sk_ids, fn sk_id ->
            !Enum.member?(skills_ids_to_exclude, sk_id)
          end)

        [cr_id, sk_ids]
      end)
      |> Enum.filter(fn craft -> List.last(craft) |> length() > 0 end)

    skills =
      Enum.map(skills, fn [sk_id, cr_ids] ->
        cr_ids =
          Enum.filter(cr_ids, fn cr_id ->
            !Enum.member?(crafts_ids_to_exclude, cr_id)
          end)

        [sk_id, cr_ids]
      end)
      |> Enum.filter(fn skill -> List.last(skill) |> length() > 0 end)

    [skills, crafts]
  end

  def get_skill_ids_by_craft_id(craft_id, crafts) do
    Enum.find(crafts, &(List.first(&1) === craft_id))
    |> List.last()
  end

  def get_necessary_skill_ids(skills, crafts) do
    [rest_crafts, crucial_skill_ids] =
      extract_one_skill_crafts(crafts)

    {_status, selected_skill_ids, journey} =
      next_craft(rest_crafts, crucial_skill_ids, skills, [], length(crafts))

    [crucial_skill_ids, selected_skill_ids, journey]
  end

  def filter_out_mandatory_skills(mandatory_skill_ids, skills, crafts) do
    skills =
      Enum.filter(skills, fn skill ->
        !Enum.member?(mandatory_skill_ids, List.first(skill))
      end)

    crafts =
      Enum.filter(crafts, fn [_cr_id, cr_sk_ids] ->
        Enum.reduce_while(cr_sk_ids, true, fn cr_sk_id, _acc ->
          if Enum.member?(mandatory_skill_ids, cr_sk_id) do
            {:halt, false}
          else
            {:cont, true}
          end
        end)
      end)

    {skills, crafts}
  end

  def extract_one_skill_crafts(crafts) do
    one_skill_only_crafts = Enum.filter(crafts, fn craft -> length(List.last(craft)) === 1 end)
    rest_crafts = Enum.filter(crafts, fn craft -> length(List.last(craft)) > 1 end)

    one_skill_only_craft_ids =
      Enum.map(one_skill_only_crafts, fn cr -> List.first(cr) end)

    selected_skill_ids =
      Enum.map(one_skill_only_craft_ids, fn cr_id ->
        get_skill_ids_by_craft_id(cr_id, crafts)
      end)
      |> List.flatten()
      |> Enum.uniq()

    rest_crafts =
      Enum.filter(rest_crafts, fn cr -> !Enum.member?(selected_skill_ids, List.last(cr)) end)

    [rest_crafts, selected_skill_ids]
  end
end
