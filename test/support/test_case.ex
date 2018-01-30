defmodule BigchaindbEx.TestCase do
  use ExUnit.CaseTemplate
  
  using do
    quote do
      use ExCheck
      import BigchaindbEx.Generators
    end
  end

  setup tags do
    :ok
  end
end