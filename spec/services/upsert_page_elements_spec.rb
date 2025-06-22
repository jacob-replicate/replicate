require "rails_helper"

describe UpsertPageElements do
  it "upserts elements + removes stale elements" do
    post = create(:post)
    unrelated_post = create(:post)
    existing_element = create(:text_element, parent_record: post, configuration: { content: "Fizz" })
    element_to_remove = create(:text_element, parent_record: post)
    element_to_remove_id = element_to_remove.id
    element_to_ignore = create(:text_element, parent_record: unrelated_post, configuration: { content: "Lorem Ipsum" })

    hashes = [
      { id: existing_element.id, type: "TextElement", configuration: { content: "Buzz" } },
      { id: nil, type: "TextElement", configuration: { content: "Foobar" } },
      { id: element_to_ignore.id, type: "VideoElement", configuration: { content: "Ignore This" } }
    ]

    UpsertPageElements.new(parent_record: post, page_element_hashes: params).call

    new_element = PageElement.where.not(id: existing_element.id)
    existing_element.reload
    element_to_ignore

    expect(PageElement.count).to eq(2)

    expect(existing_element.parent_record).to eq(post)
    expect(existing_element.configuration).to eq({ content: "Buzz" })
    expect(existing_element.class).to eq(TextElement)

    expect(new_element.parent_record).to eq(post)
    expect(new_element.configuration).to eq({ content: "Buzz" })
    expect(new_element.class).to eq(TextElement)

    expect(PageElement.where(id: element_to_remove_id).count).to eq(0)

    expect(element_to_ignore.parent_record).to eq(unrelated_post)
    expect(element_to_ignore.configuration).to eq({ content: "Lorem Ipsum" })
    expect(element_to_ignore.class).to eq(TextElement)
  end

  context "when bad data is passed in" do
    it "does nothing" do
      post = create(:post)

      hashes = [{ id: nil, type: "TextElement", configuration: { content: "Foobar" } }]

      expect {
        UpsertPageElements.new(parent_record: post, page_element_hashes: nil)
        UpsertPageElements.new(parent_record: nil, page_element_hashes: hashes)
      }.to change(PageElement.count).by(0)
    end
  end
end