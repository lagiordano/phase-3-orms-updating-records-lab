require_relative "../config/environment.rb"

class Student

  attr_accessor :id, :name, :grade

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students 
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL 
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)

      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create name, grade
    student = self.new(name, grade)
    student.save
  end

  def self.new_from_db arr
    self.new(arr[0], arr[1], arr[2])
  end

  def self.find_by_name given_name
    sql = <<-SQL 
      SELECT * 
      FROM students 
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, given_name).map do |row|
      self.new_from_db row
    end.first
  end

  def update
      sql = <<-SQL 
        UPDATE students
        SET name = ?, grade =?
        WHERE id = ?
      SQL

      DB[:conn].execute(sql, self.name, self.grade, self.id)
  end



end
