#include <smoke.h>
#include "perlqtinit.h"
#include "perlqtmetaobject.h"

// Perl headers
extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}

namespace PerlQt5 {

void initSmokeModule(Smoke* smoke, std::string nspace) {
    for (int i = 1; i <= smoke->numClasses; ++i) {
        const Smoke::Class& klass = smoke->classes[i];
        if (!klass.external) {
            std::string perlClassName = nspace + "::" + klass.className;

            // Set metaObject method
            std::string methodName = perlClassName + "::metaObject";
            newXS(methodName.c_str(), XS_QOBJECT_METAOBJECT, __FILE__);
        }
    }
}

}
