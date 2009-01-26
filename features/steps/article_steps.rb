Given /^(\d+?) published (.*?) articles?$/ do |number, klass|
  klass = get_klass(klass)
  klass.all.destroy!
  (1..number.to_i).each{ a = klass.make; a.publish! }
end


Given /^a published (.*?) article with (.*?) "(.*?)" and owned by "(.*?)"$/ do |klass, field, value, login|
  klass = get_klass(klass)
  klass.all.destroy!
  a = klass.make(field.to_sym => value, :owner => User.first(:login => login))
  a.publish!  
end

def get_klass(klass)
    klass = Object.full_const_get(klass.gsub(" ", "_").camel_case.singularize)
end