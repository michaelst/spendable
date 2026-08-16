defmodule SpendableWeb.Components.AppleMark do
  @moduledoc false
  use SpendableWeb, :html

  @doc """
  Apple's own mark, standing in as the institution logo for the accounts read out of Wallet.

  The outline is the U+F8FF glyph from the system font rather than a shape library's drawing of an
  apple. The phone renders that codepoint as text, which a browser on anything but an Apple device
  would not, so here it is the same outline inlined.
  """
  attr :class, :string, default: "size-5"

  def apple_mark(assigns) do
    ~H"""
    <svg viewBox="0 0 1261 1551" fill="currentColor" aria-hidden="true" class={@class}>
      <path d="M914 375Q936 375 989.0 382.0Q1042 389 1105.5 421.5Q1169 454 1221 529Q1218 532 1192.0 550.5Q1166 569 1134.0 604.5Q1102 640 1078.0 694.5Q1054 749 1054 824Q1054 910 1084.5 970.0Q1115 1030 1155.5 1066.5Q1196 1103 1227.5 1120.0Q1259 1137 1261 1138Q1260 1142 1235.5 1209.0Q1211 1276 1155 1358Q1106 1429 1049.5 1489.0Q993 1549 914 1549Q861 1549 827.0 1533.5Q793 1518 757.0 1502.5Q721 1487 660 1487Q601 1487 561.5 1503.0Q522 1519 486.5 1535.0Q451 1551 403 1551Q330 1551 275.0 1493.0Q220 1435 162 1354Q95 1258 47.5 1119.5Q0 981 0 840Q0 689 57.0 586.5Q114 484 203.5 431.5Q293 379 389 379Q440 379 485.0 395.5Q530 412 569.5 429.0Q609 446 641 446Q672 446 713.0 428.0Q754 410 805.0 392.5Q856 375 914 375ZM859 248Q820 295 761.0 326.5Q702 358 649 358Q638 358 628 356Q627 353 626.0 345.0Q625 337 625 328Q625 268 651.0 211.5Q677 155 710 118Q752 68 816.0 35.0Q880 2 938 0Q941 13 941 31Q941 91 918.0 147.5Q895 204 859 248Z" />
    </svg>
    """
  end
end
