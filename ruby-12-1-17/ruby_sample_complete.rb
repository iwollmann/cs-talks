require 'json'
require_relative './separated_movies_data'

# Diference between Proc and lambda 
# return difference
def proc_sample
  proc = proc { return 'world' }
  'hello ' << proc.call
end

puts proc_sample

def lambda_sample
  proc = -> { return 'world' }
  'hello ' << proc.call
end

puts lambda_sample

# Read the movies file (show with begin/end, lambda, proc and block)
file = File.read('movies.json')
movies = JSON.parse(file, symbolize_names: true)

# p lines

# Parse the data into a set of movies
class Movie
  def initialize(data)
    data.each do |key, value|
      self.class.class_eval { attr_reader key.downcase }
      instance_variable_set "@#{key.downcase}", value
    end
  end
end

# Find if a movie is from specific genre

class Movie
  def self.match_on(attr_name)
    method_name = "match_#{attr_name}"
    define_method(method_name) do |value|
      attr = send(attr_name)
      attr.include? value
    end
  end

  def initialize(data)
    data.each do |key, value|
      self.class.class_eval { attr_reader key.downcase }
      instance_variable_set "@#{key.downcase}", value

      self.class.match_on key.to_sym
    end
  end
end

star_wars = Movie.new(STAR_WARS_DATA)

p star_wars.title

p star_wars.match_genre 'Comedy'
p star_wars.match_actors 'Harrison Ford'

# Find out how many movies I have in each genre
my_movies = []
movies.each do |movie|
  my_movies << Movie.new(movie)
end

class MoviesReport
  def initialize(movies, *reports)
    @movies = movies
    @reports = reports
  end

  def run
    @reports.inject(@movies) do |last_result, report|
      report[last_result]
    end

    # total_by_comedy = @movies.inject(0) do |total, movie|
    #   total + (movie.match_genre('Comedy') ? 1 : 0)
    # end

    # total_by_horror = @movies.inject(0) do |total, movie|
    #   total + (movie.match_genre('Horror') ? 1 : 0)
    # end

    # {
    #   total_comedy_movies: total_by_comedy,
    #   total_horror_movies: total_by_horror
    # }
  end
end

total_movies = -> movies { movies.size }
select_title = -> movies { movies.map(&:title) }

comedy = -> movies { movies.select { |m| m.match_genre('Comedy') }}
horror= -> movies { movies.select { |m| m.match_genre('Horror') }}
best_three= -> movies { movies.sort{ |m| m.imdbrating.to_f }[0...2] }

p MoviesReport.new(my_movies, total_movies).run


# Find the best movies movies according Imdb rating