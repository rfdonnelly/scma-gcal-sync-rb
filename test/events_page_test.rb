require 'test_helper'

describe 'EventsPage' do
  describe 'extract_event_lines' do
    it 'works' do
      expected = {
        text: "02/28/20 - 03/01/20 Joshua Tree Indian Cove [G] @ Joshua Tree Indian Cove",
        url: "https://www.rockclimbing.org/index.php/event-list/events-list/joshua-tree-indian-cove-g-6"
      }

      o = SCMAGCal::Input::Web::EventsPage.new
      page = o.local_page('fixtures/events.html')
      actual = o.extract_event_lines(page).first

      actual.must_equal expected
    end
  end

  describe 'parse_event' do
    it 'works' do
      input = {
        text: "02/28/20 - 03/01/20 Joshua Tree Indian Cove [G] @ Joshua Tree Indian Cove",
        url: "https://www.rockclimbing.org/index.php/event-list/events-list/joshua-tree-indian-cove-g-6"
      }
      expected = {
        'start_date' => '02/28/20',
        'end_date' => '03/01/20',
        'subject' => 'Joshua Tree Indian Cove [G]',
        'location' => 'Joshua Tree Indian Cove',
        'url' => 'https://www.rockclimbing.org/index.php/event-list/events-list/joshua-tree-indian-cove-g-6',
      }

      o = SCMAGCal::Input::Web::EventsPage.new
      actual = o.parse_event(input)

      actual.must_equal expected
    end
  end
end
