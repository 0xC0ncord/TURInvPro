#define __VERSION__ 1.30.0

#define __INVPRO_MAX_WAVE_MONSTERS__        30
#define __INVPRO_MAX_MONSTER_TABLE_LEN__    1000

#define ENABLE_TURINVX_RADAR   0

#define __LINE__ #eval #line
#define __FILE__ #eval #file
#mode string QQQ "$$" "$$"
#mode push

#ifdef __DEBUG__
#define LOGD(x) Log($$"(__LINE__)"$$ @ x, Name);
#define WARND(x) Warn($$"(__LINE__)"$$ @ x);
#define CLIENTMESSAGED(x, y) x.ClientMessage(Name @ $$"(__LINE__):"$$ @ y);
#else
#define LOGD
#define WARND
#define CLIENTMESSAGED
#endif
