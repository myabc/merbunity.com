module ValidHashHelpers
  
  def valid_cast_hash
    {
      :name           => String.random,
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
    { 
      "cast[name]" => hash[:name],
      "cast[description]" => hash[:description],
      "cast[body]" => hash[:body],
      "cast[uploaded_file]" => hash[:uploaded_file]['tempfile']
    }.to_mash
  end
    
  
end