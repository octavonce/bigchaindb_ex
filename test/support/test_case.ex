defmodule BigchaindbEx.TestCase do
  use ExUnit.CaseTemplate
  
  using do
    quote do
      use EQC.ExUnit
      import BigchaindbEx.Generators
    end
  end

  setup tags do
    :ok
  end
end