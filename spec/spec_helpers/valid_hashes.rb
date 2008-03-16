module Merbunity
  module Spec
    module Helpers
      
        def valid_comment_hash
          {
            :body   => String.random(200),
            :owner  => Person.create(valid_person_hash)
          }
        end
          
        def valid_screencast_hash
          owner = Person.new(valid_person_hash)
          owner.save
          {
            :title          => String.random,
            :owner          => owner,
            :description    => String.random,
            :body           => String.random(300),
            :uploaded_file  => {
                  "content_type" => nil,
                  "size"         => 1024,
                  "filename"      => "spec_file.mov",
                  "tempfile"     => Tempfile.new("spec_file.mov")
            }
          }
        end

        def valid_multipart_screencast_mash
          hash = valid_cast_hash
          hash.delete(:owner)
          hash[:uploaded_file] = hash[:uploaded_file]["tempfile"]
          {:cast => hash}.to_mash
        end

    end
  end
end

class String
  def self.random(length = 10)
    @__avail_chars ||= (('a'..'z').to_a << ("A".."Z").to_a).flatten
    (1..length).inject(""){|out, index| out << @__avail_chars[rand(@__avail_chars.size)]}
  end
end

class Hash
  
  def with( opts )
    self.merge(opts)
  end
  
  def without(*args)
    self.dup.delete_if{ |k,v| args.include?(k)}
  end
  
end