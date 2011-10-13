class Test
  include DataMapper::Resource
  property :id, Serial
  property :test, String
  property :score, Integer
end