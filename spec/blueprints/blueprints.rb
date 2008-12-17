Sham.name       { Faker::Name.name }
Sham.title      { Faker::Lorem.sentence }
Sham.paragraph  { Faker::Lorem.paragraph }
Sham.paragraphs { Faker::Lorem.paragraphs }

NewsItem.blueprint do
  title       { Sham.name }
  description { Sham.paragraph }
  body        { Sham.paragraphs}
end