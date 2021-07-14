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

      def authored_questions
            Question.find_by_author_id(@id)
      end

      def authored_replies
            Reply.find_by_user_id(@id)
      end

      def followed_questions
          QuestionFollow.followed_questions_for_user_id(@id)  
      end

      def liked_questions
            QuestionLike.liked_questions_for_user_id(@id)
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

      def self.most_followed(n)
            QuestionFollow.most_followed_questions(n)
      end

      def initialize(options)
            @id = options['id']
            @title = options['title']
            @body = options['body']
            @user_id = options['user_id']
      end

      def author
            User.find_by_id(@user_id)
      end

      def replies
            Reply.find_by_question_id(@id)
      end

      def followers
            QuestionFollow.followers_for_question_id(@id)
      end

      def likers
            QuestionLike.likers_for_question_id(@id)
      end

      def num_likes
            QuestionLike.num_likes_for_question_id(@id)
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

      def self.find_by_parent_id(parent_id)
            data = QuestionsDatabase.instance.execute(<<-SQL, parent_id)
                  SELECT
                        *
                  FROM 
                        replies
                  WHERE
                  parent_id = ?
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

      def author
            User.find_by_id(@user_id)
      end

      def question
            Question.find_by_id(@question_id)
      end

      def parent_reply
            return self if @parent_id.nil?
            Reply.find_by_id(@parent_id)
      end

      def child_replies
            Reply.find_by_parent_id(@id)
      end

end

class QuestionFollow
      attr_accessor :id, :question_id, :user_id

      def self.all
            data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
            data.map {|datum| QuestionFollow.new(datum)}
      end

      def self.find_by_id(id)
            data = QuestionsDatabase.instance.execute(<<-SQL, id)
                  SELECT
                        *
                  FROM 
                        question_follows
                  WHERE
                        id = ?
            SQL
            return nil unless data.length > 0
            QuestionFollow.new(data.first)
      end

      def self.followers_for_question_id(question_id)
            data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
                  SELECT
                        users.id, fname, lname
                  FROM
                        question_follows JOIN users
                        ON user_id = users.id
                  WHERE
                        question_id = ?
                  
            SQL
            data.map {|datum| User.new(datum)}
      end

      def self.followed_questions_for_user_id(user_id)
            data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
                  SELECT
                        questions.id, title, body, questions.user_id
                  FROM
                        questions JOIN question_follows
                        ON questions.id = question_follows.question_id
                  WHERE
                        question_follows.user_id = ?
                  
            SQL
            data.map {|datum| Question.new(datum)}
      end

      def self.most_followed_questions(number)
            data = QuestionsDatabase.instance.execute(<<-SQL, number)
                  SELECT
                        questions.id, title, body, questions.user_id, count(*) AS count
                  FROM
                        question_follows JOIN questions 
                        ON question_id = questions.id
                  GROUP BY 
                        1  
                  ORDER BY 
                        5 DESC 
                  LIMIT ? 
            SQL

           data.map {|datum| Question.new(datum)}
      end

      def initialize(options)
            @id = options['id']
            @question_id = options['question_id']
            @user_id = options['user_id']
      end
end

class QuestionLike
      attr_accessor :id, :question_id, :user_id

      def self.all
            data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
            data.map {|datum| QuestionLike.new(datum)}
      end

      def self.find_by_id(id)
            data = QuestionsDatabase.instance.execute(<<-SQL, id)
                  SELECT
                        *
                  FROM 
                        question_likes
                  WHERE
                        id = ?
            SQL
            return nil unless data.length > 0
            QuestionLike.new(data.first)
      end

      def self.likers_for_question_id(question_id)
            data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
                  SELECT
                        users.id, fname, lname
                  FROM
                        users JOIN
                        question_likes ON question_likes.user_id = users.id
                  WHERE
                        question_id = ?
            SQL
            data.map {|datum| User.new(datum)}
      end

      def self.num_likes_for_question_id(question_id)
            data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
                  SELECT
                        count(*)
                  FROM
                        question_likes
                  where
                        question_id = ?
                  group by
                        question_id
            SQL
            return nil if data.empty?
            data[0].values[0]
      end

      def self.liked_questions_for_user_id(user_id)
            data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT
                  questions.id, title, body, questions.user_id
            FROM
                  question_likes Join
                  questions ON questions.id = question_id
            where
                  question_likes.user_id = ?
            SQL
            return nil if data.empty?
            Question.new(data.first)
      end

      def initialize(options)
            @id = options['id']
            @question_id = options['question_id']
            @user_id = options['user_id']
      end
end