require_relative "../config/environment.rb"
require "pry"

class Student
  attr_accessor :id, :name, :grade
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  @@all = []

  def initialize(id = nil, name, grade)
  	@id = id
  	@name = name
  	@grade = grade
  	@@all << self
  end

  def self.create_table
  	sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
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
	      INSERT INTO students (name, grade) VALUES (?, ?)
	  	SQL
	  	DB[:conn].execute(sql, self.name, self.grade)
	  	@id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
	  end
  	self
  end

  def self.create(name, grade)
  	new_stud = Student.new(name, grade)
  	new_stud.save
    new_stud
  end

  def self.new_from_db(row)
    Student.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
  	sql = <<-SQL
      SELECT * FROM students WHERE name = ?
  	SQL
  	new_stud = DB[:conn].execute(sql, name)[0]
  	Student.new_from_db(new_stud)
  end

  def update
  	sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?
  	SQL
  	DB[:conn].execute(sql, self.name, self.grade, self.id)
  	self
  end

end
