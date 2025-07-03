//
// PUBLIC DOMAIN CRT STYLED SCAN-LINE SHADER
//
//   by Timothy Lottes
//
// This is more along the style of a really good CGA arcade monitor.
// With RGB inputs instead of NTSC.
// The shadow mask example has the mask rotated 90 degrees for less chromatic aberration.
//
// Left it unoptimized to show the theory behind the algorithm.
//
// It is an example what I personally would want as a display option for pixel art games.
// Please take and use, change, or whatever.
//
shader_type canvas_item;

uniform vec2 screen_size;
uniform vec2 viewport_size;
uniform float hardScan:hint_range(-20.0, 0.0, 1.0)=-8.0;
uniform float hardPix:hint_range(-20.0, 0.0, 1.0)=-3.0;
uniform float warpX:hint_range(0.0, 0.125, 0.001)=0.031;
uniform float warpY:hint_range(0.0, 0.125, 0.001)=0.041;
uniform float maskDark:hint_range(0.0, 2.0, 0.1)=0.5;
uniform float maskLight:hint_range(0.0, 2.0, 0.1)=1.5;
uniform bool scaleInLinearGamma=true;
uniform int shadowMask:hint_range(0, 4, 1)=3;
uniform float brightBoost:hint_range(0.0, 2.0, 0.05)=1.0;
uniform float hardBloomPix:hint_range(-2.0, -0.5, 0.1)=-1.5;
uniform float hardBloomScan:hint_range(-4.0, -1.0, 0.1)=-2.0;
uniform float bloomAmount:hint_range(0.0, 1.0, 0.05)=0.15;
uniform float shape:hint_range(0.0, 10.0, 0.05)=2.0;
uniform bool doBloom=true;

uniform sampler2D CRTBackBuffer:hint_screen_texture;

#define warp vec2(warpX,warpY)

float ToLinear1(float c)
{
	if (scaleInLinearGamma==false) {return c;}
	return(c<=0.04045)?c/12.92:pow((c+0.055)/1.055,2.4);
}
vec3 ToLinear(vec3 c)
{
	if (scaleInLinearGamma==false) {return c;}
	return vec3(ToLinear1(c.r),ToLinear1(c.g),ToLinear1(c.b));
}
float ToSrgb1(float c)
{
	if (scaleInLinearGamma==false) {return c;}
	return (c<0.0031308?c*12.92:1.055*pow(c,0.41666)-0.055);
}

vec3 ToSrgb(vec3 c)
{
	if (scaleInLinearGamma==false) {return c;}
	return vec3(ToSrgb1(c.r),ToSrgb1(c.g),ToSrgb1(c.b));
}
vec3 Fetch(vec2 pos,vec2 off){
  vec2 res = screen_size;
  pos=(floor(pos*res.xy+off)+vec2(0.5,0.5))/res.xy;
  if(max(abs(pos.x-0.5),abs(pos.y-0.5))>0.5)return vec3(0.0,0.0,0.0);
  return ToLinear(brightBoost * texture(CRTBackBuffer,pos.xy).rgb);
}

vec2 Dist(vec2 pos){
	vec2 res = screen_size;

	pos=pos*res;
	return -((pos-floor(pos))-vec2(0.5,0.5));
}
float Gaus(float pos,float scale){return exp2(scale*pow(abs(pos),shape));}
vec3 Horz3(vec2 pos,float off){
  vec3 b=Fetch(pos,vec2(-1.0,off));
  vec3 c=Fetch(pos,vec2( 0.0,off));
  vec3 d=Fetch(pos,vec2( 1.0,off));
  float dst=Dist(pos).x;
  // Convert distance to weight.
  float scale=hardPix;
  float wb=Gaus(dst-1.0,scale);
  float wc=Gaus(dst+0.0,scale);
  float wd=Gaus(dst+1.0,scale);
  // Return filtered sample.
  return (b*wb+c*wc+d*wd)/(wb+wc+wd);}

vec3 Horz5(vec2 pos,float off){
  vec3 a=Fetch(pos,vec2(-2.0,off));
  vec3 b=Fetch(pos,vec2(-1.0,off));
  vec3 c=Fetch(pos,vec2( 0.0,off));
  vec3 d=Fetch(pos,vec2( 1.0,off));
  vec3 e=Fetch(pos,vec2( 2.0,off));
  float dst=Dist(pos).x;
  // Convert distance to weight.
  float scale=hardPix;
  float wa=Gaus(dst-2.0,scale);
  float wb=Gaus(dst-1.0,scale);
  float wc=Gaus(dst+0.0,scale);
  float wd=Gaus(dst+1.0,scale);
  float we=Gaus(dst+2.0,scale);
  // Return filtered sample.
  return (a*wa+b*wb+c*wc+d*wd+e*we)/(wa+wb+wc+wd+we);}

vec3 Horz7( vec2 pos,float off){
  vec3 a=Fetch(pos,vec2(-3.0,off));
  vec3 b=Fetch(pos,vec2(-2.0,off));
  vec3 c=Fetch(pos,vec2(-1.0,off));
  vec3 d=Fetch(pos,vec2( 0.0,off));
  vec3 e=Fetch(pos,vec2( 1.0,off));
  vec3 f=Fetch(pos,vec2( 2.0,off));
  vec3 g=Fetch(pos,vec2( 3.0,off));
  float dst=Dist(pos).x;
  // Convert distance to weight.
  float scale=hardBloomPix;
  float wa=Gaus(dst-3.0,scale);
  float wb=Gaus(dst-2.0,scale);
  float wc=Gaus(dst-1.0,scale);
  float wd=Gaus(dst+0.0,scale);
  float we=Gaus(dst+1.0,scale);
  float wf=Gaus(dst+2.0,scale);
  float wg=Gaus(dst+3.0,scale);
  // Return filtered sample.
  return (a*wa+b*wb+c*wc+d*wd+e*we+f*wf+g*wg)/(wa+wb+wc+wd+we+wf+wg);}

float Scan(vec2 pos,float off){
  float dst=Dist(pos).y;
  return Gaus(dst+off,hardScan);}

float BloomScan(vec2 pos,float off){
  float dst=Dist(pos).y;
  return Gaus(dst+off,hardBloomScan);}

vec3 Tri(vec2 pos){
  vec3 a=Horz3(pos,-1.0);
  vec3 b=Horz5(pos, 0.0);
  vec3 c=Horz3(pos, 1.0);
  float wa=Scan(pos,-1.0);
  float wb=Scan(pos, 0.0);
  float wc=Scan(pos, 1.0);
  return a*wa+b*wb+c*wc;}

vec3 Bloom(vec2 pos){
  vec3 a=Horz5(pos,-2.0);
  vec3 b=Horz7(pos,-1.0);
  vec3 c=Horz7(pos, 0.0);
  vec3 d=Horz7(pos, 1.0);
  vec3 e=Horz5(pos, 2.0);
  float wa=BloomScan(pos,-2.0);
  float wb=BloomScan(pos,-1.0);
  float wc=BloomScan(pos, 0.0);
  float wd=BloomScan(pos, 1.0);
  float we=BloomScan(pos, 2.0);
  return a*wa+b*wb+c*wc+d*wd+e*we;}

vec2 Warp(vec2 pos){
  pos=pos*2.0-1.0;
  pos*=vec2(1.0+(pos.y*pos.y)*warp.x,1.0+(pos.x*pos.x)*warp.y);
  return pos*0.5+0.5;}

vec3 Mask(vec2 pos){
  vec3 mask=vec3(maskDark,maskDark,maskDark);

  // Very compressed TV style shadow mask.
  if (shadowMask == 1) {
    float sline=maskLight;
    float odd=0.0;
    if(fract(pos.x/6.0)<0.5)odd=1.0;
    if(fract((pos.y+odd)/2.0)<0.5)sline=maskDark;
    pos.x=fract(pos.x/3.0);

    if(pos.x<0.333)mask.r=maskLight;
    else if(pos.x<0.666)mask.g=maskLight;
    else mask.b=maskLight;
    mask*=sline;
  }

  // Aperture-grille.
  else if (shadowMask == 2) {
    pos.x=fract(pos.x/3.0);

    if(pos.x<0.333)mask.r=maskLight;
    else if(pos.x<0.666)mask.g=maskLight;
    else mask.b=maskLight;
  }

  // Stretched VGA style shadow mask (same as prior shaders).
  else if (shadowMask == 3) {
    pos.x+=pos.y*3.0;
    pos.x=fract(pos.x/6.0);

    if(pos.x<0.333)mask.r=maskLight;
    else if(pos.x<0.666)mask.g=maskLight;
    else mask.b=maskLight;
  }

  // VGA style shadow mask.
  else if (shadowMask == 4) {
    pos.xy=floor(pos.xy*vec2(1.0,0.5));
    pos.x+=pos.y*3.0;
    pos.x=fract(pos.x/6.0);

    if(pos.x<0.333)mask.r=maskLight;
    else if(pos.x<0.666)mask.g=maskLight;
    else mask.b=maskLight;
  }

  return mask;}

void fragment(){
	vec2 ppos=Warp(UV.xy*(screen_size/viewport_size)*(viewport_size/screen_size));
	vec3 outColor=Tri(ppos);

	if (doBloom==true) {outColor.rgb+=(Bloom(ppos)*bloomAmount);}
	outColor.rgb;
	if (shadowMask>=0){outColor.rgb*=(Mask(floor(UV.xy*(screen_size/viewport_size)/SCREEN_PIXEL_SIZE)+vec2(0.5,0.5)));}
	outColor.rgb;

	COLOR = (vec4(ToSrgb(outColor.rgb),1.0));
}