Given /^no (.*?) exist$/ do |klass|
  klass = get_klass(klass)
  klass.all.destroy!
end

def get_klass(klass)
  klass = Object.full_const_get(klass.gsub(" ", "_").camel_case.singularize)
end
