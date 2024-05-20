defmodule SpendableWeb.Live.Login.HTML do
  use LiveViewNative.Component, format: :html
  use SpendableWeb, :html


    def render(assigns, _interface) do
      ~H"""
      <.flash_group flash={@flash} />
      <div class="left-[40rem] fixed inset-y-0 right-0 z-0 hidden lg:block xl:left-[50rem]">
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
      <div class="px-4 py-10 sm:px-6 sm:py-28 lg:px-8 xl:px-28 xl:py-32 bg-white h-full">
        <div class="mx-auto max-w-xl lg:mx-0">
          <img class="h-12" src={~p"/images/full-logo.svg"} alt="Spendable" />
          <p class="text-[1.5rem] mt-8 font-semibold leading-10 tracking-tighter text-brand">
            Privacy focused budgeting.
          </p>
          <.link
            navigate={~p"/auth/google"}
            class="mt-10 flex w-full items-center justify-center gap-3 rounded-md bg-[#ffffff] p-3 text-[#444] focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#24292F] border border-[#444]"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              xmlns:v="https://vecta.io/nano"
              width="705.6"
              height="720"
              viewBox="0 0 186.69 190.5"
              class="h-5 w-5"
            >
              <g transform="translate(1184.583 765.171)">
                <path
                  clip-path="none"
                  mask="none"
                  d="M-1089.333-687.239v36.888h51.262c-2.251 11.863-9.006 21.908-19.137 28.662l30.913 23.986c18.011-16.625 28.402-41.044 28.402-70.052 0-6.754-.606-13.249-1.732-19.483z"
                  fill="#4285f4"
                /><path
                  clip-path="none"
                  mask="none"
                  d="M-1142.714-651.791l-6.972 5.337-24.679 19.223h0c15.673 31.086 47.796 52.561 85.03 52.561 25.717 0 47.278-8.486 63.038-23.033l-30.913-23.986c-8.486 5.715-19.31 9.179-32.125 9.179-24.765 0-45.806-16.712-53.34-39.226z"
                  fill="#34a853"
                /><path
                  clip-path="none"
                  mask="none"
                  d="M-1174.365-712.61c-6.494 12.815-10.217 27.276-10.217 42.689s3.723 29.874 10.217 42.689c0 .086 31.693-24.592 31.693-24.592-1.905-5.715-3.031-11.776-3.031-18.098s1.126-12.383 3.031-18.098z"
                  fill="#fbbc05"
                /><path
                  d="M-1089.333-727.244c14.028 0 26.497 4.849 36.455 14.201l27.276-27.276c-16.539-15.413-38.013-24.852-63.731-24.852-37.234 0-69.359 21.388-85.032 52.561l31.692 24.592c7.533-22.514 28.575-39.226 53.34-39.226z"
                  fill="#ea4335"
                  clip-path="none"
                  mask="none"
                />
              </g>
            </svg>
            <span class="text-sm font-semibold leading-6">Sign in with Google</span>
          </.link>
          <div class="flex">
            <div class="w-full sm:w-auto">
              <div class="mt-10 grid grid-cols-1 gap-x-6 gap-y-4 sm:grid-cols-3">
                <a
                  href={~p"/privacy-policy"}
                  class="group relative rounded-2xl px-6 py-4 text-sm font-semibold leading-6 text-zinc-900 sm:py-6"
                >
                  <span class="absolute inset-0 rounded-2xl bg-zinc-50 transition group-hover:bg-zinc-100 sm:group-hover:scale-105">
                  </span>
                  <span class="relative flex items-center gap-4 sm:flex-col">
                    <svg viewBox="0 0 24 24" fill="none" aria-hidden="true" class="h-6 w-6">
                      <path d="m12 4 10-2v18l-10 2V4Z" fill="#18181B" fill-opacity=".15" />
                      <path
                        d="M12 4 2 2v18l10 2m0-18v18m0-18 10-2v18l-10 2"
                        stroke="#18181B"
                        stroke-width="2"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      />
                    </svg>
                    Privacy Policy
                  </span>
                </a>
                <a
                  href="https://github.com/michaelst/spendable"
                  class="group relative rounded-2xl px-6 py-4 text-sm font-semibold leading-6 text-zinc-900 sm:py-6"
                  target="_blank"
                >
                  <span class="absolute inset-0 rounded-2xl bg-zinc-50 transition group-hover:bg-zinc-100 sm:group-hover:scale-105">
                  </span>
                  <span class="relative flex items-center gap-4 sm:flex-col">
                    <svg viewBox="0 0 24 24" aria-hidden="true" class="h-6 w-6">
                      <path
                        fill-rule="evenodd"
                        clip-rule="evenodd"
                        d="M12 0C5.37 0 0 5.506 0 12.303c0 5.445 3.435 10.043 8.205 11.674.6.107.825-.262.825-.585 0-.292-.015-1.261-.015-2.291C6 21.67 5.22 20.346 4.98 19.654c-.135-.354-.72-1.446-1.23-1.738-.42-.23-1.02-.8-.015-.815.945-.015 1.62.892 1.845 1.261 1.08 1.86 2.805 1.338 3.495 1.015.105-.8.42-1.338.765-1.645-2.67-.308-5.46-1.37-5.46-6.075 0-1.338.465-2.446 1.23-3.307-.12-.308-.54-1.569.12-3.26 0 0 1.005-.323 3.3 1.26.96-.276 1.98-.415 3-.415s2.04.139 3 .416c2.295-1.6 3.3-1.261 3.3-1.261.66 1.691.24 2.952.12 3.26.765.861 1.23 1.953 1.23 3.307 0 4.721-2.805 5.767-5.475 6.075.435.384.81 1.122.81 2.276 0 1.645-.015 2.968-.015 3.383 0 .323.225.707.825.585a12.047 12.047 0 0 0 5.919-4.489A12.536 12.536 0 0 0 24 12.304C24 5.505 18.63 0 12 0Z"
                        fill="#18181B"
                      />
                    </svg>
                    Source Code
                  </span>
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
      """
    end
end
