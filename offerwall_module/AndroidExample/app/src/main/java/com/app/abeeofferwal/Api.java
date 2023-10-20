package com.app.abeeofferwal;

import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.common.StandardMessageCodec;




public class  Api{
    public static class Offerwall {
        //  memId: "abee997", memGen: "w", memBirth: "2000-01-01", memRegion: "인천_서"

        public String getMemId() {
            return memId;
        }

        public void setMemId(String memId) {
            this.memId = memId;
        }

        public String getMemGen() {
            return memGen;
        }

        public void setMemGen(String memGen) {
            this.memGen = memGen;
        }

        public String getMemBirth() {
            return memBirth;
        }

        public void setMemBirth(String memBirth) {
            this.memBirth = memBirth;
        }

        public String getMemRegion() {
            return memRegion;
        }

        public void setMemRegion(String memRegion) {
            this.memRegion = memRegion;
        }
        public String getFirebaseKey() {
            return firebaseKey;
        }

        public void setFirebaseKey(String firebaseKey) {
            this.firebaseKey = firebaseKey;
        }
        private String memId;
        private String memGen;
        private String memBirth;
        private String memRegion;
        private String firebaseKey;

        Map<String, Object> toMap() {
            Map<String, Object> toMapResult = new HashMap<>();
            toMapResult.put("memId", getMemId());
            toMapResult.put("memGen", getMemGen());
            toMapResult.put("memBirth", getMemBirth());
            toMapResult.put("memRegion", getMemRegion());
            toMapResult.put("firebaseKey", getFirebaseKey());

            return toMapResult;
        }
        static Offerwall fromMap(Map<String, Object> map) {
            Offerwall fromMapResult = new Offerwall();
//            Object title = map.get("title");
            fromMapResult.memId = (String)map.get("memId");
            fromMapResult.memGen = (String)map.get("memGen");
            fromMapResult.memBirth = (String)map.get("memBirth");
            fromMapResult.memRegion = (String)map.get("memRegion");
            fromMapResult.firebaseKey = (String)map.get("firebaseKey");
            return fromMapResult;
        }
    }

    private static class HostOfferwallApiCodec extends StandardMessageCodec {
        public static final HostOfferwallApiCodec INSTANCE = new HostOfferwallApiCodec();
        private HostOfferwallApiCodec() {}
        @Override
        protected Object readValueOfType(byte type, ByteBuffer buffer) {
            switch (type) {
                case (byte)128:
                    return Offerwall.fromMap((Map<String, Object>)readValue(buffer));

                default:
                    return super.readValueOfType(type, buffer);
            }
        }
        @Override
        protected void writeValue(ByteArrayOutputStream stream, Object value) {
            if (value instanceof Offerwall) {
                stream.write(128);
                writeValue(stream, ((Offerwall)value).toMap());
            } else {
                super.writeValue(stream, value);
            }
        }
    }
    public interface HostOfferwallApi {
        void cancel();

        /** The codec used by HostOfferwallApi. */
        static MessageCodec<Object> getCodec() { return HostOfferwallApiCodec.INSTANCE; }

        /**
         * Sets up an instance of `HostOfferwallApi` to handle messages through the
         * `binaryMessenger`.
         */
        static void setup(BinaryMessenger binaryMessenger, HostOfferwallApi api) {
            {
                BasicMessageChannel<Object> channel = new BasicMessageChannel<>(
                        binaryMessenger, "dev.flutter.pigeon.HostOfferwallApi.cancel",
                        getCodec());
                if (api != null) {
                    channel.setMessageHandler((message, reply) -> {
                        Map<String, Object> wrapped = new HashMap<>();
                        try {
                            api.cancel();
                            wrapped.put("result", null);
                        } catch (Error | RuntimeException exception) {
                            wrapped.put("error", wrapError(exception));
                        }
                        reply.reply(wrapped);
                    });
                } else {
                    channel.setMessageHandler(null);
                }
            }
//            {
//                BasicMessageChannel<Object> channel = new BasicMessageChannel<>(
//                        binaryMessenger, "dev.flutter.pigeon.HostBookApi.finishEditingBook",
//                        getCodec());
//                if (api != null) {
//                    channel.setMessageHandler((message, reply) -> {
//                        Map<String, Object> wrapped = new HashMap<>();
//                        try {
//                            ArrayList<Object> args = (ArrayList<Object>)message;
//                            Book bookArg = (Book)args.get(0);
//                            if (bookArg == null) {
//                                throw new NullPointerException("bookArg unexpectedly null.");
//                            }
//                            api.finishEditingBook(bookArg);
//                            wrapped.put("result", null);
//                        } catch (Error | RuntimeException exception) {
//                            wrapped.put("error", wrapError(exception));
//                        }
//                        reply.reply(wrapped);
//                    });
//                } else {
//                    channel.setMessageHandler(null);
//                }
//            }
        }
    }


    public static class FlutterOfferwallApi {
        private final BinaryMessenger binaryMessenger;
        public FlutterOfferwallApi(BinaryMessenger argBinaryMessenger) {
            this.binaryMessenger = argBinaryMessenger;
        }
        public interface Reply<T> {
            void reply(T reply);
        }
        static MessageCodec<Object> getCodec() {
            return FlutterOfferwallApiCodec.INSTANCE;
        }

        public void displayOfferwallDetails(Offerwall bookArg, Reply<Void> callback) {
            BasicMessageChannel<Object> channel = new BasicMessageChannel<>(
                    binaryMessenger,
                    "dev.flutter.pigeon.FlutterBookApi.displayBookDetails", getCodec());
            channel.send(new ArrayList<Object>(Arrays.asList(bookArg)),
                    channelReply -> { callback.reply(null); });
        }
    }
    private static class FlutterOfferwallApiCodec extends StandardMessageCodec {
        public static final FlutterOfferwallApiCodec INSTANCE =
                new FlutterOfferwallApiCodec();
        private FlutterOfferwallApiCodec() {}
        @Override
        protected Object readValueOfType(byte type, ByteBuffer buffer) {
            switch (type) {
                case (byte)128:
                    return Offerwall.fromMap((Map<String, Object>)readValue(buffer));

                default:
                    return super.readValueOfType(type, buffer);
            }
        }
        @Override
        protected void writeValue(ByteArrayOutputStream stream, Object value) {
            if (value instanceof Offerwall) {
                stream.write(128);
                writeValue(stream, ((Offerwall)value).toMap());
            } else {
                super.writeValue(stream, value);
            }
        }
    }

    private static Map<String, Object> wrapError(Throwable exception) {
        Map<String, Object> errorMap = new HashMap<>();
        errorMap.put("message", exception.toString());
        errorMap.put("code", exception.getClass().getSimpleName());
        errorMap.put("details", null);
        return errorMap;
    }
}