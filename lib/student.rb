require 'pry'
require_relative "../config/environment.rb"

class Student

  attr_accessor :id, :name, :grade

  def initialize(id=nil, name, grade)
    @id, @name, @grade = id, name, grade
  end

  def self.create_table
    sql = <<-SQL
    create table students (
      id integer primary key,
      name text,
      grade integer
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("drop table students;")
  end

  def save
    if self.id.nil?
      sql = <<-SQL
      insert into students (name, grade)
      values (?, ?);
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("select last_insert_rowid();")[0][0]
    else
      self.update
    end
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    student = self.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    row = DB[:conn].execute("select * from students where name = ?", name)
    self.new_from_db(row[0])
  end

  def update
    sql = "update students set name = ?, grade = ? where id = ?;"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
