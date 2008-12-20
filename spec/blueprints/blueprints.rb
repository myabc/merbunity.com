Sham.name       { Faker::Name.name }
Sham.title      { Faker::Lorem.sentence }
Sham.paragraph  { Faker::Lorem.paragraph }
Sham.paragraphs { Faker::Lorem.paragraphs }
Sham.word       { Faker::Lorem.words(1)}

NewsItem.blueprint do
  title       { Sham.name }
  description { Sham.paragraph }
  body        { Sham.paragraphs}
end

Tutorial.blueprint do
  title       { Sham.name }
  description { Sham.paragraph }
  body        { Sham.paragraphs}
end


User.blueprint do
  login                 { Sham.name }
  password              { Sham.word }
  password_confirmation { password }
end