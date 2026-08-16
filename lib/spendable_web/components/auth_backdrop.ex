defmodule SpendableWeb.Components.AuthBackdrop do
  @moduledoc false
  use SpendableWeb, :html

  @doc """
  The blue panel behind every page a signed-out visitor can land on.

  Shared so the consent screen is visibly the sign-in page's twin: the two are the only places an
  outsider decides whether to trust this app, and they should not look like different products.
  """
  attr :class, :string, default: nil

  def auth_backdrop(assigns) do
    ~H"""
    <div class={["left-[40rem] fixed inset-y-0 right-0 z-0 hidden lg:block xl:left-[50rem]", @class]}>
      <svg
        viewBox="0 0 1480 957"
        fill="none"
        aria-hidden="true"
        class="absolute inset-0 h-full w-full"
        preserveAspectRatio="xMinYMid slice"
      >
        <path fill="#2E77C7" d="M0 0h1480v957H0z" />
        <path
          d="M137.542 466.27c-582.851-48.41-988.806-82.127-1608.412 658.2l67.39 810 3083.15-256.51L1535.94-49.622l-98.36 8.183C1269.29 281.468 734.115 515.799 146.47 467.012l-8.928-.742Z"
          fill="#3C8AD7"
        />
        <path
          d="M371.028 528.664C-169.369 304.988-545.754 149.198-1361.45 665.565l-182.58 792.025 3014.73 694.98 389.42-1689.25-96.18-22.171C1505.28 697.438 924.153 757.586 379.305 532.09l-8.277-3.426Z"
          fill="#4E9DE4"
        />
        <path
          d="M359.326 571.714C-104.765 215.795-428.003-32.102-1349.55 255.554l-282.3 1224.596 3047.04 722.01 312.24-1354.467C1411.25 1028.3 834.355 935.995 366.435 577.166l-7.109-5.452Z"
          fill="#65B0ED"
          fill-opacity=".6"
        />
        <path
          d="M1593.87 1236.88c-352.15 92.63-885.498-145.85-1244.602-613.557l-5.455-7.105C-12.347 152.31-260.41-170.8-1225-131.458l-368.63 1599.048 3057.19 704.76 130.31-935.47Z"
          fill="#82C3F5"
          fill-opacity=".2"
        />
        <path
          d="M1411.91 1526.93c-363.79 15.71-834.312-330.6-1085.883-863.909l-3.822-8.102C72.704 125.95-101.074-242.476-1052.01-408.907l-699.85 1484.267 2837.75 1338.01 326.02-886.44Z"
          fill="#A4D5FA"
          fill-opacity=".2"
        />
        <path
          d="M1116.26 1863.69c-355.457-78.98-720.318-535.27-825.287-1115.521l-1.594-8.816C185.286 163.833 112.786-237.016-762.678-643.898L-1822.83 608.665 571.922 2635.55l544.338-771.86Z"
          fill="#A4D5FA"
          fill-opacity=".2"
        />
      </svg>
    </div>
    """
  end
end
