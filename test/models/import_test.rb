require 'test_helper'

class ImportTest < ActiveSupport::TestCase

  test "bad ged file" do
    ign = Import.from_gedfile('test-tree', 'test/fixtures/files/badtest.ged','badtest.ged', false)
    assert_equal ign, "Ignoring all _UID, REFN or CHAN fields
Other ignored lines follow:
PROBLEMS in import.rb"
  end
  
  test "import normal" do

    ign = Import.from_gedfile('test-tree', 'test/fixtures/files/test.ged','test.ged', false)

    assert_equal ign[0..1305], "Ignoring all _UID, REFN or CHAN fields
Other ignored lines follow:
Header : 0 HEAD 
Header : 1 SOUR PAF
Header : 2 NAME Personal Ancestral File
Header : 2 VERS 5.2.18.0
Header : 2 CORP The Church of Jesus Christ of Latter-day Saints
Header : 3 ADDR 50 East North Temple Street
Header : 4 CONT Salt Lake City, UT 84150
Header : 4 CONT USA
Header : 1 SUBM @SUB1@
Submitter : 0 @SUB1@ SUBM
Submitter : 1 NAME John Doe
Submitter : 1 DEST Other
Submitter : 1 DATE 4 Apr 2006
Submitter : 2 TIME 21:43:54
Submitter : 1 FILE stammbaum.ged
Submitter : 1 GEDC
Submitter : 2 VERS 5.5
Submitter : 2 FORM LINEAGE-LINKED
Submitter : 1 CHAR UTF-8
Submitter : 1 LANG English
Joe /Miller/: 2 SURN 
Hermann /Miller/: 2 GIVN 
Ignored individual death: 6 INVALID
Ignored individual source: 6 INVALID
Ignored individual note: 6 INVALID
Ignored individual child: 6 INVALID
Ignored individual : 6 INVALID
Ignored individual birth: 6 INVALID
|Ignored individual death: 6 INVALID
Ignored union marriage: 6 INVALID
Ignored union divorce: 6 INVALID
Ignored union marriage: 6 INVALID
Ignored union source: 6 INVALID
Ignored union note: 6 INVALID
Ignored union : 6 INVALID
Ignored source content: 6 INVALID
Ignored source title: 2 WHAT ever
Repo : 0 @REPO1@ REPO
Repo : 0 @REPO2@ REPO
Repo : 0 @REPO3@ REPO
Repo : 0 @REPO4@ REPO
0 TRLR"


  end
  
end
