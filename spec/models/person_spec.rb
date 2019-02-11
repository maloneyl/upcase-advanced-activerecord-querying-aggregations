require "spec_helper"

describe Person do
  describe ".average_salary" do
    it "finds the average salary across all people" do
      create(:person, salary: 40_000)
      create(:person, salary: 30_000)

      expect(Person.average_salary).to eq(35_000)
    end
  end

  describe ".non_billable_salaries" do
    it "finds the salaries of all people in non-billable roles" do
      create(:person, role: create(:role, billable: true), salary: 10_000)
      create(:person, role: create(:role, billable: false), salary: 20_000)
      create(:person, role: create(:role, billable: true), salary: 30_000)
      create(:person, role: create(:role, billable: false), salary: 40_000)

      result = Person.non_billable_salaries

      expect(result).to eq(60_000)
    end
  end

  describe ".average_salary_by_role" do
    it "finds the average salary by role" do
      create(:person, role: create(:role, name: "Researcher"), salary: 40_000)
      create(:person, role: create(:role, name: "Researcher"), salary: 50_000)
      create(:person, role: create(:role, name: "Designer"), salary: 55_000)
      create(:person, role: create(:role, name: "Designer"), salary: 45_000)

      result = Person.average_salary_by_role

      expect(result).to eq(
        "Designer" => 50_000,
        "Researcher" => 45_000
      )
    end
  end

  describe ".employee_count" do
    it "counts employees for each person, including those who have no employees" do
      manager_a = create(:person, name: "Manager A", manager: nil)
      employee_a = create(:person, name: "Employee A", manager: manager_a)
      manager_b = create(:person, name: "Manager B", manager: nil)
      employee_b1 = create(:person, name: "Employee B1", manager: manager_b)
      employee_b2 = create(:person, name: "Employee B2", manager: manager_b)

      result = Person.employee_count

      expect(result).to eq(
        "Employee A" => 0,
        "Employee B1" => 0,
        "Employee B2" => 0,
        "Manager A" => 1,
        "Manager B" => 2
      )
    end
  end

  describe ".with_lower_than_average_salaries_at_location" do
    it "finds people with lower than average salaries at their location" do
      location = create(:location)
      create(:person, location: location, salary: 40_000)
      create(:person, location: location, salary: 35_000)
      low_paid_person = create(:person, location: location, salary: 20_000)

      result = Person.with_lower_than_average_salaries_at_location

      expect(result).to eq([low_paid_person])
    end
  end

  describe ".highest_salaried_ordered_by_name" do
    it "finds the highest salaried people, ordered by name" do
      top_earner = create(:person, name: "One", salary: 100_000)
      second_highest_earner = create(:person, name: "Two", salary: 80_000)
      third_highest_earner = create(:person, name: "Three", salary: 75_000)
      normal_earner = create(:person, name: "Nope", salary: 50_000)

      result = Person.highest_salaried_ordered_by_name

      expect(result.map(&:name)).to eq(%w(One Three Two))
    end
  end

  describe ".maximum_salary_by_location" do
    it "finds the highest salary at each location" do
      [50_000, 60_000].each do |highest_salary|
        location = create(:location, name: "highest-#{highest_salary}")
        create(:person, location: location, salary: highest_salary - 1)
        create(:person, location: location, salary: highest_salary)
      end

      result = Person.maximum_salary_by_location

      expect(find_names(result)).to eq(
        "highest-50000" => 50_000,
        "highest-60000" => 60_000
      )
    end
  end

  def find_names(hash_by_id)
    hash_by_id.inject({}) do |hash_by_name, (id, value)|
      name = Location.find(id).name
      hash_by_name.merge(name => value)
    end
  end

  describe ".managers_by_average_salary_difference" do
    it "orders managers by the difference between their salary and the average salary of their employees" do
      highest_difference = [45_000, 20_000]
      medium_difference = [50_000, 10_000]
      lowest_difference = [50_000, -5_000]
      ordered_differences = [highest_difference, medium_difference, lowest_difference]

      ordered_differences.each do |(salary, difference)|
        manager = create(:person, salary: salary, name: "difference-#{difference}")
        create(:person, manager: manager, salary: salary - difference * 1)
        create(:person, manager: manager, salary: salary - difference * 2)
        create(:person, manager: manager, salary: salary - difference * 3)
      end

      result = Person.managers_by_average_salary_difference

      expect(result.map(&:name)).to eq(%w(
        difference-20000
        difference-10000
        difference--5000
      ))
    end
  end
end
