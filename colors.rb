class Colors

  def self.colorize(str="")
    val = []
    hex = "0123456789abcdef"
    str.strip.split('').each do |char|
      value = ""
      value = char if hex.include? char
      value = "0" unless hex.include? char
      val << value
    end
    val = val.join("")
    if val.length % 3 > 0
      (3 - val.length % 3).times do
        val = val + "0"
      end
    end
    arr = val.scan(/.{#{val.length/3}}/)
    color = arr.map { |ele| ele[0..1] }.join("")
    if color.length == 3
      color = color.split('').map {|char| "#{char}#{char}"}.join("")
    end
    color
  end


  def self.colorize_file
    text = File.read("lib/words.csv")
    hsh = {}
    CSV.parse(text, :headers => true,) do |row|
      hsh[row] = self.colorize(row["word"].strip)
    end
    CSV.open("lib/words_colors.csv","wb") do |csv|
      csv << ["word","color"]
      hsh.keys.each do |key|
        csv<< [key.to_s.strip,hsh[key].to_s]
      end
    end
    return true
  end

  def self.invert_colorized_file
    text = File.read("lib/words_colors.csv")
    hsh = {}
    CSV.parse(text, :headers => true,) do |row|
      color = row["color"]
      word = row["word"]
      hsh[color] = [word] if hsh[color].blank?
      hsh[color] << word  unless hsh[color].blank?
    end
    CSV.open("lib/colors_words.csv","wb") do |csv|
      csv << ["color","words"]
      hsh.keys.each do |key|
        csv<< [key.to_s.strip,hsh[key].join("|")]
      end
    end
    return true
  end

  def self.worderize(rgb)
    numeric = "0123456789"
    alpha = "abcdef"
    colors = [rgb]
    indicies = []
    rgb.split('').each_with_index { |ele,idx| indicies << idx if numeric.include? ele }
    hsh = {}
    #debugger
    indicies.each do |idx|
      newcolors = []
      colors.each do |color|
        newcolors << color.gsub(color[idx],"0") 
        newcolors << color.gsub(color[idx],"a")
      end
      colors = newcolors
    end
    colors
  end

  def self.full_prep
    Colors.colorize_file
    Colors.invert_colorized_file
  end

  def self.get_words(rgb)
    text = File.read("lib/colors_words.csv")
    hsh = {}
    words_arr = []
    CSV.parse(text, :headers => true,) do |row|
      color = row["color"]
      words = row["words"]
      hsh[color] = words
    end
    colors = self.worderize(rgb)
    colors.each do  |color|
      words_arr = words_arr + hsh[color].split("|") unless hsh[color].blank?
    end
    words_arr.uniq
  end

end
