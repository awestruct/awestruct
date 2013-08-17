unless File.respond_to?(:binread)
  def File.binread(file)
    File.open(file,"rb") { |f| f.read }
  end
end
