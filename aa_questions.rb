require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
      include Singleton

      def initialize
            super('aa_questions.db')
            self.type_translation = true
            self.results_as_hash = true
      end
end

class User

      attr_accessor :id, :fname, :lname

      def self.all
            data = QuestionsDatabase.instance.execute("SELECT * FROM users")
            data.map {|datum| User.new(datum)}
      end

      def self.find_by_id(id)
            data = QuestionsDatabase.instance.execute(<<-SQL, id)
                  SELECT
                        *
                  FROM 
                        users
                  WHERE
                        id = ?
            SQL
            return nil unless data.length > 0
            User.new(data.first)
      end

      def self.find_by_name(fname, lname)
            data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
                  SELECT
                        *
                  FROM 
                        users
                  WHERE
                        fname = ? AND lname = ?
                        
            SQL
            return nil unless data.length > 0
            User.new(data.first)
      end

      def initialize(options)
            @id = options['id']
            @fname = options['fname']
            @lname = options['lname']
      end
end

class Question

      attr_accessor :id, :title, :body, :user_id

      def self.all
            data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
            data.map {|datum| Question.new(datum)}
      end

      def self.find_by_id(id)
            data = QuestionsDatabase.instance.execute(<<-SQL, id)
                  SELECT
                        *
                  FROM 
                        questions
                  WHERE
                        id = ?
            SQL
            return nil unless data.length > 0
            Question.new(data.first)
      end

      def  self.find_by_author_id(user_id)
            data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
                  SELECT
                        *
                  FROM 
                        questions
                  WHERE
                        user_id = ?
            SQL
            return nil unless data.length > 0
            data.map {|user| Question.new(user)}
      end

      def initialize(options)
            @id = options['id']
            @title = options['title']
            @body = options['body']
            @user_id = options['user_id']
      end
end

class Reply

      attr_accessor :id, :parent_id, :user_id, :body, :question_id

      def self.all
            data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
            data.map {|datum| Reply.new(datum)}
      end

      def self.find_by_id(id)
            data = QuestionsDatabase.instance.execute(<<-SQL, id)
                  SELECT
                        *
                  FROM 
                        replies
                  WHERE
                        id = ?
            SQL
            return nil unless data.length > 0
            Reply.new(data.first)
      end

      def self.find_by_user_id(user_id)
            data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
                  SELECT
                        *
                  FROM 
                        replies
                  WHERE
                        user_id = ?
            SQL
            return nil unless data.length > 0
            data.map {|user| Reply.new(user)}
      end

      def self.find_by_question_id(question_id)
            data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
                  SELECT
                        *
                  FROM 
                        replies
                  WHERE
                        question_id = ?
            SQL
            return nil unless data.length > 0
            data.map {|question| Reply.new(question)}
      end

      def initialize(options)
            @id = options['id']
            @parent_id = options['parent_id']
            @user_id = options['user_id']
            @body = options['body']
            @question_id = options['question_id']
      end
end