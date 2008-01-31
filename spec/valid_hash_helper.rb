module ValidHashHelpers
  
  def valid_cast_hash
    {
      :title           => String.random,
      :person         => Person.new(valid_person_hash),
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
  
  def valid_multipart_cast_mash
    hash = valid_cast_hash
    hash.delete(:person)
    hash[:uploaded_file] = hash[:uploaded_file]["tempfile"]
    {:cast => hash}.to_mash
  end
    
  
end