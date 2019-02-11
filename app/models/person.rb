class Person < ActiveRecord::Base
  belongs_to :location
  belongs_to :role
  belongs_to :manager, class_name: "Person", foreign_key: :manager_id
  has_many :employees, class_name: "Person", foreign_key: :manager_id

  def self.average_salary
    average(:salary)
  end

  def self.non_billable_salaries
    joins(:role).
    where(roles: { billable: false }).
    sum(:salary)
  end

  def self.average_salary_by_role
    joins(:role).
    group("roles.name").
    average(:salary)
  end

  def self.employee_count
    joins(
      "LEFT JOIN people employees ON employees.manager_id = people.id"
    ).
    group("people.name").
    count("employees.id")
  end

  def self.with_lower_than_average_salaries_at_location
    joins(
      "INNER JOIN (" +
        self.
          select("location_id, AVG(salary) as average").
          group("location_id").
          to_sql +
      ") salaries " \
      "ON salaries.location_id = people.location_id"
    ).
    where("people.salary < salaries.average")
  end

  def self.highest_salaried_ordered_by_name
    joins(
      "INNER JOIN (" +
        self.
          select("id, rank() OVER (ORDER BY salary DESC)").
          to_sql +
      ") salaries " \
      "ON salaries.id = people.id"
    ).
    where("salaries.rank <= 3").
    order(:name)
  end

  def self.maximum_salary_by_location
    group(:location_id).maximum(:salary)
  end

  def self.managers_by_average_salary_difference
    joins(
      "INNER JOIN (" +
        self.
          select("manager_id, AVG(salary) as average_employee_salary").
          group("manager_id").
          to_sql +
      ") salaries " \
      "ON salaries.manager_id = people.id"
    ).
    order("(people.salary - salaries.average_employee_salary) DESC")
  end
end
