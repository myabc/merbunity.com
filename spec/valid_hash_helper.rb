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
  
end