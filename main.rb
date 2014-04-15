# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    main.rb                                            :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: svachere <svachere@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2014/01/19 17:11:09 by svachere          #+#    #+#              #
#    Updated: 2014/04/15 16:14:27 by svachere         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

require "open-uri"
require "nokogiri"
require "ansi/code"

# 			aboufatima time		42 time
# soubh		06:29	
# dohr		13:09				13:15
# asr		15:53				15:50
# Maghrib	18:31				18:25
# Isha		20:01				19:45

LAST_VERSIO_URL = "https://raw.githubusercontent.com/illiatdesdindes/42mouslim/master/version"
PRAYER_URL = "http://www.aboufatima.com/horaire-priere/fr/paris-18002.html"
VERSION_FILE = File.expand_path('../version', __FILE__)
LAST_VERSION_FILE = File.expand_path('../tmp', __FILE__)

class Fixnum
	def minutes
		self * 60
	end
end

class Version

  def self.check
    system("curl -s #{LAST_VERSIO_URL} > #{LAST_VERSION_FILE}")
    last_version = File.read(LAST_VERSION_FILE)
    current_version = File.read(VERSION_FILE)
    if last_version.strip != current_version.strip
      puts ANSI.red + 
          "\nThere is a new version of 42mouslim" + 
          "\nYou should :" + 
          "\n - git pull the project" + 
          "\n   or " +
          "\n - git clone git@github.com:illiatdesdindes/42mouslim.git "+ 
          ANSI.reset
    end
    system("rm #{LAST_VERSION_FILE}")
  end
end

class Horraire

	attr_accessor :times

	def initialize
		doc = Nokogiri::HTML(open(PRAYER_URL))
		tr = doc.css(".table_horaire_day tr")[1]
		@times = {}
		@times[:dohr] = Time.parse(tr.children[2].text) + 1.minutes
		@times[:asr] = Time.parse(tr.children[3].text) - 9.minutes
		@times[:maghrib] = Time.parse(tr.children[4].text) - 3.minutes
		@times[:isha] = Time.parse(tr.children[5].text) - 16.minutes
		@alarm = 13.minutes
	end

	def run
		while true
			now = Time.now
			@times.each do |k, time|
				if time - @alarm < now
					alarm k, time
				end
			end
			notprayertime
			sleep 1
		end
	end

	def nextprayer
		@times.each do |prayer, time|
			if  Time.now < time
				return "#{prayer} at #{time.strftime("%R")}"
			end
			"tomorrow"
		end
	end

	def notprayertime
		text = 	"\n#######################################################" +
				"\n" +
				"\n    Nothing for now. Next is #{nextprayer}" +
				"\n" +
				"\n#######################################################"
		print ANSI.green + text + ANSI.reset
	end

	def alarm(prayer, time)
		stop = time
		toggle = 0
		while Time.now < stop
			min_remain = Time.at(time - Time.now).strftime("%M:%S")
			text = 	"\n#######################################################" +
					"\n" +
					"\n     it's #{prayer} time, adhan at #{time.strftime("%R")}" +
					"\n                in #{min_remain} minutes " +
					"\n#######################################################"
			toggle = (toggle + 1) % 2
			if toggle == 0
				print ANSI.yellow
			else
				print ANSI.blue
			end
			print text + ANSI.reset
			sleep 0.1
		end
	end

end

Version.check

h = Horraire.new
h.run
