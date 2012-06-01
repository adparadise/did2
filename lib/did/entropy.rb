

class Did::Entropy
  attr_reader :priority

  def build(sheet)
    build_tags_list sheet
    build_counts
    calculate_uniqueness
  end

  def build_tags_list(sheet)
    @tags_list = Set.new(sheet.map {|time, tags| tags.sort.uniq}).to_a
  end

  def build_counts
    @tag_counts = {}
    @pair_counts = {}
    @tags_list.each do |tags|
      tags.each do |tag|
        @tag_counts[tag] = (@tag_counts[tag] || 0) + 1
      end
      tags.combination(2) do |pair|
        pair_string = pair.sort.join("-")
        @pair_counts[pair_string] = (@pair_counts[pair_string] || 0) + 1
      end
    end
  end
  
  def calculate_uniqueness
    max_pair = @pair_counts.values.max
    tag_uniqueness = {}
    @pair_counts.each do |pair_string, count|
      pair = pair_string.split("-")
      uniqueness = (max_pair - count + 1) * @tag_counts[pair[0]] * @tag_counts[pair[1]]
      
      tag_uniqueness[pair[0]] = (tag_uniqueness[pair[0]] || 0) + uniqueness
      tag_uniqueness[pair[1]] = (tag_uniqueness[pair[1]] || 0) + uniqueness
    end

    @priority = tag_uniqueness.keys.sort do |a, b|
      tag_uniqueness[b] <=> tag_uniqueness[a]
    end
  end
end
