require 'net/http'

class SpotCrimeFetcher
  @queue = :fetcher_queue

  def self.perform(lat, lon, radius)
    s='http://api.spotcrime.com/crimes.json?'
    s=s+'lat='+lat.to_s
    s=s+'&lon='+lon.to_s
    s=s+'&radius='+radius.to_s
    s=s+'&key=MLC'

    uri = URI(s)
    data = Net::HTTP.get(uri)

    result = JSON.parse(data)

    result['crimes'].each do |report|
      puts report.inspect

      report_hash = {}

      case report['type']
      when 'Assault'
        report_hash[:type] =  2
      when 'Robbery'
        report_hash[:type] =  3
      when 'Shooting'
        report_hash[:type] =  1
      when 'Theft'
        report_hash[:type] =  3
      when 'Burglary'
        report_hash[:type] =  3
      else
        report_hash[:type] =  4
      end

      report_hash[:latitude] = report['lat']
      report_hash[:longitude] = report['lon']
      report_hash[:date] = Time.strptime(report['date'], '%m/%d/%y %I:%M %p')

      @report = Report.new(report_hash)
      @report.save
    end
  end

end
