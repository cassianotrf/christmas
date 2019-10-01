require "open-uri"
require "nokogiri"
require "pry"
require "csv"

puts "Welcome to the Christmas List"

gift_list = {}

CSV.foreach("lib/presents.csv") do |present|
  gift_list[present[0]] = (present[1] ? true : false)
end

action = ""
until action == "exit"
  puts "- - - - - - - - -"
  puts "What do you want to do? [List|Add|Delete|Mark|Inspiration|Exit]"
  action = gets.chomp.downcase

  case action
  when "list"
    puts "You currently have #{gift_list.length} items in your list"
    gift_list.each do |item, status|
      puts "#{status ? "[x]" : "[ ]"} - #{item}"
    end

  when "add"
    puts "What do you want to add?"
    new_present = gets.chomp.downcase
    gift_list[new_present] = false
    puts "#{new_present} has been added to your list"

  when "delete"
    puts "Which item do you want to delete?"
    gift_list.each do |item, status|
      puts "- #{item}"
    end
    user_delete = gets.chomp.downcase
    gift_list.delete(user_delete)
    puts "#{user_delete} has been deleted from your list"

  when "mark"
    puts "What item would you like to mark as bought?"
    item_bought = gets.chomp.downcase
    gift_list[item_bought] = !gift_list[item_bought]

  when "inspiration"
    puts "What gift ideas do you need?"
    article = gets.chomp

    file = open("https://www.etsy.com/search?q=#{article}")
    doc = Nokogiri::HTML(file)
    doc_search = doc.search(".card-title").first(6)

    doc_search.each_with_index do |gift, index|
      puts "#{index + 1} - #{gift.text.strip}"
    end

    puts ""
    puts "Which one do you want to add to your list?"
    web_add = gets.chomp.to_i

    new_key = doc_search[web_add - 1].text.strip.split.first(3).join(" ").downcase
    puts "You chose to add: #{doc_search[web_add - 1].text.strip}"
    gift_list[new_key] = false

  when "exit"
    puts "Exiting... See you next time!"
    CSV.open("presents.csv", 'wb') do |csv|
      gift_list.each do |item, status|
        csv << [item, status]
      end
    end

  else
    puts "Incorrect action"
  end
end