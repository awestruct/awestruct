# Generates a sitemap for search engines.  Defaults to /sitemap.xml
# Ignores images, css, robots, atoms, javascript files.
# Add a sitemap.yml file to add files that for one reason or
# another won't be hanging off of site (e.g. they're in .htaccess)
require 'ostruct'

module Awestruct
  module Extensions
    class Sitemap

      def execute( site )

        # Go through all of the site's pages and add sitemap metadata
        sitemap_pages = []
        entries = site.pages
        entries.each { |entry| sitemap_pages << set_sitemap_data( entry ) if valid_sitemap_entry( entry ) } if entries

        # Generate sitemap pages for stuff in _config/sitemap.yml
        site.sitemap.pages.each do |entry|
          page = Awestruct::Renderable.new( site )
          page.output_path = entry.url
          page.date = entry.date( nil )
          page.priority = entry.priority( nil )
          page.change_frequency = entry.change_frequency( nil )
          sitemap_pages << page
        end if site.sitemap

        # Generate the correct urls for each page in the sitemap
        site.engine.set_urls( sitemap_pages )

        # Create a sitemap.xml file from our template
        sitemap = File.join( File.dirname(__FILE__), 'sitemap.xml.haml' )
        page                 = site.engine.load_page( sitemap )
        page.output_path     = 'sitemap.xml'
        page.sitemap_entries = sitemap_pages

        # Add the sitemap to our site
        site.pages << page
      end

      protected

      def set_sitemap_data( page )
        site = page.site
        munge_date( page )
        page.priority         ||= (site.priority or 0.1)
        page.change_frequency ||= (site.change_frequency or 'never')
        page
      end

      def munge_date( page )
        date = page.date
        if date
          begin
            if date.kind_of? String
              page.lastmod = Time.parse( page.date ).strftime( "%Y-%m-%d" )
            else
              page.lastmod = date.strftime( "%Y-%m-%d" )
            end
          rescue Exception => e
            puts "[ERROR] Cannot parse date #{date.to_s}: #{e}"
          end
        else
          page.lastmod = Time.now.strftime( "%Y-%m-%d" )
        end
      end

      def valid_sitemap_entry( page )
        page.output_filename != '.htaccess'     &&
          page.output_filename  != 'screen.css' &&
          page.output_filename  != 'print.css'  &&
          page.output_filename  != 'ie.css'     &&
          page.output_filename  != 'robots.txt' &&
          page.output_extension != '.atom'      &&
          page.output_extension != '.scss'      &&
          page.output_extension != '.css'       &&
          page.output_extension != '.png'       &&
          page.output_extension != '.jpg'       &&
          page.output_extension != '.gif'       &&
          page.output_extension != '.js'
      end

    end
  end
end
