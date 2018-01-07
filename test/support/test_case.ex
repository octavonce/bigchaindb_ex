defmodule BigchainEx.TestCase do
  use ExUnit.CaseTemplate
  
  using do
    quote do
      use EQC.ExUnit
      import BigchainEx.Generators
    end
  end

  setup tags do
    :ok
  end
end