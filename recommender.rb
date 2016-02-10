require_relative 'recommend_for.rb'

class Recommender

  attr_reader :data, :distance

  def initialize(data)
    @data = data
    @distance = :inverse_euclidean_distance
  end

  def shared_items(user1, user2)
    data[user1].keys & data[user2].keys
  end

  def inverse_euclidean_distance(user1, user2)
    1/(1 + Math.sqrt(shared_items(user1, user2).reduce(0) do |acc, item_title|
      acc + (data[user1][item_title] - data[user2][item_title])**2
    end))
  end

  def reviewers_ordered_by_similarity_to(user)
    (data.keys - [user]).map do |reviewer|
      [send(distance, user, reviewer), reviewer]
    end.sort.reverse
  end

  def closest_reviewer_to(user)
    reviewers_ordered_by_similarity_to(user).first
  end

  def pearson_correlation(user1, user2)

  end

  def adjusted_ratings_by_similarity_to(user)
    similarity_ratings = reviewers_ordered_by_similarity_to(user)
    similarity_ratings.map do |sim, reviewer|
      [sim, data[reviewer].map do |item_title, rating|
        [item_title, rating*sim]
      end.to_h]
    end
  end

  def predicted_rating_for(user, item_title)
    ratings = adjusted_ratings_by_similarity_to(user)
    fraction = ratings.reduce([0,0]) do |acc, sim_ratings|
      if rate = sim_ratings[1][item_title]
        [acc[0] + sim_ratings[0], acc[1] + rate]
      else
        acc
      end
    end
    fraction[1]/fraction[0].to_f
  end
end

r = Recommender.new(RecommendFor.movie_data)
user1 = 'Claudia Puig'
user2 = 'Michael Phillips'
p r.shared_items(user1, user2)
p r.inverse_euclidean_distance(user1, user2)

user1 = 'Lisa Rose'
user2 = 'Gene Seymour'
p r.shared_items(user1, user2)
p r.inverse_euclidean_distance(user1, user2)

user = 'Jack Matthews'
p closest = r.closest_reviewer_to(user)

user = 'Toby'
p closest = r.closest_reviewer_to(user)

# p r.adjusted_ratings_by_similarity_to(user)
p r.predicted_rating_for(user, 'Snakes on a Plane')
