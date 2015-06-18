/* C++ code produced by gperf version 3.0.4 */
/* Command-line: gperf -L C++ -E -t /tmp/pablo/kanka-bluetooth-generated/KrollGeneratedBindings.gperf  */
/* Computed positions: -k'' */

#line 3 "/tmp/pablo/kanka-bluetooth-generated/KrollGeneratedBindings.gperf"


#include <string.h>
#include <v8.h>
#include <KrollBindings.h>

#include "com.ewin.kanka.bluetooth.ExampleProxy.h"
#include "com.ewin.kanka.bluetooth.KankaBluetoothModule.h"


#line 14 "/tmp/pablo/kanka-bluetooth-generated/KrollGeneratedBindings.gperf"
struct titanium::bindings::BindEntry;
/* maximum key range = 9, duplicates = 0 */

class KankaBluetoothBindings
{
private:
  static inline unsigned int hash (const char *str, unsigned int len);
public:
  static struct titanium::bindings::BindEntry *lookupGeneratedInit (const char *str, unsigned int len);
};

inline /*ARGSUSED*/
unsigned int
KankaBluetoothBindings::hash (register const char *str, register unsigned int len)
{
  return len;
}

struct titanium::bindings::BindEntry *
KankaBluetoothBindings::lookupGeneratedInit (register const char *str, register unsigned int len)
{
  enum
    {
      TOTAL_KEYWORDS = 2,
      MIN_WORD_LENGTH = 37,
      MAX_WORD_LENGTH = 45,
      MIN_HASH_VALUE = 37,
      MAX_HASH_VALUE = 45
    };

  static struct titanium::bindings::BindEntry wordlist[] =
    {
      {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""},
      {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""},
      {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""},
      {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""},
      {""},
#line 16 "/tmp/pablo/kanka-bluetooth-generated/KrollGeneratedBindings.gperf"
      {"com.ewin.kanka.bluetooth.ExampleProxy", ::com::ewin::kanka::bluetooth::kankabluetooth::ExampleProxy::bindProxy, ::com::ewin::kanka::bluetooth::kankabluetooth::ExampleProxy::dispose},
      {""}, {""}, {""}, {""}, {""}, {""}, {""},
#line 17 "/tmp/pablo/kanka-bluetooth-generated/KrollGeneratedBindings.gperf"
      {"com.ewin.kanka.bluetooth.KankaBluetoothModule", ::com::ewin::kanka::bluetooth::KankaBluetoothModule::bindProxy, ::com::ewin::kanka::bluetooth::KankaBluetoothModule::dispose}
    };

  if (len <= MAX_WORD_LENGTH && len >= MIN_WORD_LENGTH)
    {
      register int key = hash (str, len);

      if (key <= MAX_HASH_VALUE && key >= 0)
        {
          register const char *s = wordlist[key].name;

          if (*str == *s && !strcmp (str + 1, s + 1))
            return &wordlist[key];
        }
    }
  return 0;
}
#line 18 "/tmp/pablo/kanka-bluetooth-generated/KrollGeneratedBindings.gperf"

