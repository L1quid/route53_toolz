# update the contact details on many domains at once
# this example sets Admin, Registrant, and Tech details to the same contact
# uses aws-cli, which should already be configured

# gems required: json, highline

require "json"
require "highline"

filter = /\.(com|net|org)$/i

begin
  puts "Requesting domain list from AWS..."
  domains = JSON.parse(`aws route53domains list-domains`)
  domains = domains["Domains"]
rescue StandardError => e
  puts "Error parsing aws response\n#{e.inspect}"
  exit(0)
end

puts "Total domains in AWS: #{domains.length}"
puts "Filtering by: #{filter}"

filtered_domains = domains.select {|x| x["DomainName"].match(filter)}

puts "Domains to update: #{filtered_domains.length}"
puts "Domains:"

filtered_domains.each {|x| puts "  #{x["DomainName"]}"}

begin
  contact_info = File.read("contact.json")
  contact_info = JSON.parse(contact_info)
rescue StandardError => e
  puts "Error parsing ./contact.json\n#{e.inspect}"
  puts "Aborting update!"
  exit(0)
end

begin
  privacy_info = File.read("privacy.json")
  privacy_info = JSON.parse(privacy_info)
rescue StandardError => e
  puts "Error parsing ./privacy.json\n#{e.inspect}"
  puts "Aborting update!"
  exit(0)
end

exit unless HighLine.agree("Do you want to update the contact info of the preceding list of #{filtered_domains.length} domains?")