require 'open-uri'
require 'nokogiri'

def parse_html( url )
	charset = nil
	html = open(url) do |f|
	  charset = f.charset
	  f.read
	end

	return Nokogiri::HTML.parse( html, nil, charset )
end

areas = []
kawabo_url = 'http://www.river.go.jp/'

doc = parse_html( kawabo_url + 'nrpc0701gDisp.do' )

doc.xpath( '//tr' ).each do |node|
	areas.push( {
			name: 	node.css('td.area').inner_text.delete( "\t\t\r\n\t\t" ),
			url:  	kawabo_url + node.css('td.link a').attribute('href').value	
		} )
end

areas.each do |area|
	doc = parse_html( area[:url] )
	dams = []

	p area[:name]

	doc.xpath( '//table[@class="spread2"]/tr' ).each do |node|
		if( node.css('td>a').inner_text != "" )then
			dam_doc = parse_html( node.css('td>a').attribute('href').value )

			if( dam_doc.xpath( '//a[last()]' ).attribute('href').value.index("Dsp") != nil )then
				dam_dsp_doc = parse_html( "http://www1.river.go.jp" + dam_doc.xpath( '//a[last()]' ).attribute('href').value )

				dams.push( {
					name: 	node.css('td:first-child').inner_text.delete( "\t\t\r\n\t\t" ),
					url: 		"http://www1.river.go.jp" + dam_dsp_doc.xpath( '//a[img]' ).attribute('href').value
				} )

				p node.css('td:first-child').inner_text.delete( "\t\t\r\n\t\t" )

				url = "http://www1.river.go.jp" + dam_dsp_doc.xpath( '//a[img]' ).attribute('href').value

				filename = File.basename(url)
		    open(filename, 'wb') do |file|
		        open(url) do |data|
		            file.write(data.read)
		      end
		    end
			end
		end
	end

	area[:dams] = dams
end