namespace :db do
  desc "Erase and fill database"
  def regex_song
    /(?m)((?<=(\\begin{songtext})|(\\newpage)).*?(?=(\\newpage)|(\\end{songt)))/
  end
  def regex_title
    /(?<=\\songtitle{).*(?=})/
  end
  def regex_meta
    /(?m)((?<=(\\begin{songmeta})|(\\newpage)).*?(?=(\\newpage)|(\\end{songm)))/
  end
  def double_backslash
    /\\\\\s*/
  end
  def quotes
    /\\textquotedblleft{}|\\textquotedblright{}/
  end
  def dots
    /\\ldots/
  end
  def add_to_db(attributes)
    @song = Song.new(attributes)
    @song.save
  end
  def sanitize(string)
    string.gsub(dots, "...").gsub(quotes, '"').gsub(double_backslash, '')
  end
  def all_songs_to_db
    list = []
    i = 0
    @songs = Song.all
    Dir.foreach('db/songs') do |item|
      next if item == '.' or item == '..' or !item.end_with?('.tex')
      f = File.open("db/songs/"+item, "r")
      raw_text = f.read
      hash = {
        id: i,
        title: sanitize(regex_title.match(raw_text).to_s),
        meta: sanitize(regex_meta.match(raw_text).to_s),
        text: sanitize(regex_song.match(raw_text).to_s)}
      list.push(hash)
      i+=1
      add_to_db(hash)
    end
    list
  end
  task populate: :environment do
    Song.delete_all
    all_songs_to_db
  end
end