class DeepStruct < OpenStruct
  def self.load_issue
    new(JSON.parse(Rails.root.join('lib/hdo/fake_issue.json').read))
  end

  def initialize(hash = nil)
    @table = {}
    @hash_table = {}

    if hash
      hash.each do |k, v|
        put(k, v)
      end
    end
  end

  def to_h
    @hash_table
  end

  def put(k, v)
    @hash_table[k.to_sym] = v
    @table[k.to_sym] = convert(v)

    new_ostruct_member(k)
  end

  def method_missing(meth, *args, &blk)
    unless meth =~ /=/ || @table.has_key?(meth)
      raise NoMethodError, "undefined method #{meth.inspect} for #{inspect}"
    end

    super
  end

  private

  def convert(v)
    case v
    when Hash
      self.class.new(v)
    when Array
      v.map { |e| convert(e) }
    when /^\d{4}-\d{2}-\d{2}T/
      Time.parse(v)
    else
      v
    end
  end
end
