require 'json'

# Read the movies File
movies = JSON.parse(File.read('movies.json'), symbolize_names: true)

# Parse the data into a set of movies

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
      # self.class.add_attribute(key.downcase, value)
      self.class.class_eval { attr_reader key.downcase }

      instance_variable_set "@#{key.downcase}", value

      self.class.match_on key.downcase
    end
  end
end 

movie = Movie.new(movies[0])


# Find if a movie is from specific genre

# Find out how many commedies
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
    @reports.inject(@movies) do |list_movies, report|
      report[list_movies]
    end
    # { total_comedies: @movies.select { |m| m.match_genre 'Comedy' }.size }
  end
end

only_comedy = -> movies { movies.select { |m| m.match_genre 'Comedy' }}
best_three = -> movies { movies.sort { |m| m.imdbrating.to_f }[0...2]}
select_title = -> movies { movies.map(&:title) }

p MoviesReport.new(my_movies, only_comedy, best_three, select_title).run
# Find the best movies movies according Imdb rating