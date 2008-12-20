Given /^no (.*?) exist$/ do |klass|
  klass = get_klass(klass)
  klass.all.destroy!
end
