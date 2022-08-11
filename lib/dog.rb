require 'pry'

class Dog

    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            ) 
            SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)

        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

        self

    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
    end


    # From my own understanding, since this is a class method, self.new is the same as Song.new, and we are initializing it with the values obtained from a particular row in the db table. 
    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    # Returns an array of rows from teh database that matches the query, which we can then map over to create a new ruby object for each row
    def self.all
        sql = <<-SQL
            SELECT * FROM dogs
        SQL

        DB[:conn].execute(sql).map do |row|
            self.new_from_db(row)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL

        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find(id)
        sql = <<-SQL
            SELECT * FROM dogs 
            WHERE id = ?
            LIMIT 1
        SQL

        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        # binding.pry
        result = self.find_by_name(name)
        

        # If there's no match from the name, immediately creates new entry to db. Skipped over if not. 
        if result == nil
            self.create(name: name, breed: breed)
        end

        # If there is a match, check for breed. If the breed matches, that means the name already matches, so it will then just return the matching dog
        # If there's no match (meaning there's a dog of the name but different breed, will create a new dog)
        if result.breed == breed
            self.find(result.id)
        elsif
            new_dog = self.create(name: name, breed: breed)
            # binding.pry
            new_dog
        end
    end






end
