require_relative '../../spec_helper'
require 'pathspec/spec'

describe Spec do
  subject { Spec.new }

  it "does not allow matching" do
    expect { subject.match "anything" }.to raise_error
  end

  it { is_expected.to be_inclusive  }
end
